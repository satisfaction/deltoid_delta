# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.
require 'thread'
require 'memcache'
require 'drb'
require 'yaml'

class Deltoid
  
  def initialize(sphinx_config_file = nil, memcached_config_file = nil)
    @sphinx_config_file     = sphinx_config_file
    @memcached_config_file  = memcached_config_file
  end
  
  def logger
    DaemonKit.logger
  end
  
  def check_path_for_executables!
    %w[pgrep indexer searchd].each do |command|
      `which #{command}`
      if $?.exitstatus != 0
        logger.error("Failed to find #{command.inspect} command on the PATH!")
      end
    end
  end
  
  # ===== SPHINX CONFIG ================================================================================================
  
  def sphinx_config_file
    @sphinx_config_file || DaemonKit.arguments.options[:sphinx_config_file]
  end

  def sphinx_pid
    result = `pgrep searchd`.strip.to_i
    if result > 0
      result
    else
      nil
    end
  end
  
  def sphinx_running?
    sphinx_pid != nil
  end
  
  def sphinx_client
    @sphinx_client ||=
      if sphinx_config_file != nil
      
        config_data = File.read(sphinx_config_file)
        if match = /\s+listen = (\S+):(\d+)\s*/.match(config_data)
          Riddle::Client.new(match[1], match[2].to_i)
        else
          Riddle::Client.new
        end
      
      else
        Riddle::Client.new
      end
  end
  
  # ===== INDEXES ======================================================================================================
  
  def stale_indexes?
    stale_index_prefixes.count > 0
  end
  
  def stale_index_prefixes
    delta_index_prefixes.select { |index_prefix|
      cache_get(memcached_key_for_index(index_prefix)) != nil
    }
  end
  
  def delta_index_prefixes
    @delta_index_prefixes ||=
      begin
        index_prefixes = []
    
        File.read(sphinx_config_file).each_line do |line|
          if match = /^\s*index (\w+)_delta : (\w+)_core\s*$/.match(line)
            delta_name = match[1]
            core_name = match[2]
        
            if delta_name == core_name
              index_prefixes << match[1]
            end
          end
        end
    
        index_prefixes
      end
  end
  
  def clear_stale_index_with_prefix(index_prefix)
    cache_delete(memcached_key_for_index(index_prefix))
  end
  
  def memcached_key_for_index(index_prefix)
    "#{index_prefix}_index_is_stale"
  end
  
  # ===== CACHE ========================================================================================================
  
  def memcached_config_file
    @memcached_config_file || DaemonKit.arguments.options[:memcached_yml_file]
  end
  
  def cache
    @cache ||=
      if memcached_config_file
        
        memcache_configs = ::YAML.load_file(memcached_config_file)
        if active_config = memcache_configs[DAEMON_ENV]
          defaults = memcache_configs['defaults'] || {}
          
          active_config = defaults.merge(active_config)
          active_config.keys.each do |config_key|
            value = active_config.delete(config_key)
            
            # skip blank values, which will prevent memcache-client defaults from appearing
            if value != nil && (!value.kind_of?(String) || value =~ /\S/)
              active_config[config_key.to_sym] = value
            end
          end
          active_config[:multithread] = true
          logger.debug("Using memcache config: #{active_config.inspect}")
          
          servers = active_config.delete(:servers)
          MemCache.new(*([servers, active_config].flatten))
        else
          MemCache.new('localhost:11211', :multithread => true)
        end
        
      else
        MemCache.new('localhost:11211', :multithread => true)
      end
      
  end
  
  def cache_get(key)
    unless cache.servers.all? { |server| server.retry && server.retry > Time.now }
      cache.get(key, true)
    end
  rescue MemCache::MemCacheError => e
    if e.message =~ /Timeout\:\:Error/
      logger.debug(e.class.name + ": " + e.message)
      nil
    else
      raise
    end
  end
  
  def cache_delete(key)
    cache.delete(key)
  end
  
  # ===== REINDEXING ===================================================================================================
  
  def run_indexer_for_stale_indexes(stale_sphinx_indexes)
    delta_index_names = stale_sphinx_indexes.collect { |index_prefix| "#{index_prefix}_delta" }
    result = `indexer #{"--rotate" if sphinx_running?} --config "#{sphinx_config_file}" #{delta_index_names.join(' ')}`
    if $?.exitstatus == 0
      logger.info(result)
      
      true
    else
      # error of some sort!
      logger.error(result)
      false
    end
  end
    
  INDEXER_MUTEX = Mutex.new
  
  def index_block(blocking = false)
    if blocking
      INDEXER_MUTEX.synchronize { yield }
    elsif INDEXER_MUTEX.try_lock
      begin
        yield
      ensure
        INDEXER_MUTEX.unlock
      end
    else # couldn't get the lock!
      return false
    end
  end
  
  def reindex_stale_delta_indexes!(blocking = false)
    index_block(blocking) do
      
      stale_index_prefixes = self.stale_index_prefixes
      if stale_index_prefixes.count > 0
        logger.info "Found #{stale_index_prefixes.count} stale indexes: #{stale_index_prefixes.inspect}"

        start = Time.now
        
        # clear the flags in memcached
        stale_index_prefixes.each do |index_prefix|
          clear_stale_index_with_prefix(index_prefix)
        end
        
        # reindex the stale indexes...
        run_indexer_for_stale_indexes(stale_index_prefixes)

        @last_delta_index_time = Time.now - start

        @delta_index_count = 0 if @delta_index_count.nil?
        @delta_index_count += 1
      end
      
    end
    
  end
  
  def reindex_main_indexes!(blocking = false)
    index_block(blocking) do
      logger.info "Reindexing main+delta indexes"
      
      start = Time.now

      # reset any dirty flags, since we'll reindex everything...
      delta_index_prefixes.each do |index_prefix|
        clear_stale_index_with_prefix(index_prefix)
      end
      
      result = `indexer --config "#{sphinx_config_file}" #{"--rotate" if sphinx_running?} --all`
      if $?.exitstatus == 0
        logger.info(result)

        @last_core_index_time = Time.now - start

        @core_index_count = 0 if @core_index_count.nil?
        @core_index_count += 1
                
        true
      else
        # error of some sort!
        logger.error(result)
        false
      end
    end
  end

  def get_status
    status = {
      :delta_index_count => @delta_index_count || 0,
      :core_index_count => @core_index_count || 0,
      :last_delta_index_time => @last_delta_index_time || 0,
      :last_core_index_time => @last_core_index_time || 0
    }

    status.to_yaml
  end

  
end

# ===== STATS SERVER =================================================================================================

class DeltoidStatusServer
  include DRbUndumped

  def initialize(deltoid)
    @deltoid = deltoid
  end

  def get_status
    @deltoid.get_status
  end

end

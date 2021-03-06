require 'yaml'

namespace :thinking_sphinx do
  
  desc "Marks all indexes as stale, forcing a delta reindex"
  task :mark_indexes_as_stale => :app_env do
    require 'deltoid_delta'
    DeltoidDelta.mark_indexes_as_stale
  end
  
end

namespace :ts do
  desc "Marks all indexes as stale, forcing a delta reindex"
  task :mark => "thinking_sphinx:mark_indexes_as_stale"
end

namespace :deltoid do
  
  task :init do
    @deltoid_env = ENV["DELTOID_ENV"] || ENV["DAEMON_ENV"] || Rails.env
    @deltoid_root = File.expand_path("../../../vendor/deltoid_daemon", __FILE__)
    
    @deltoid_bin_dir = File.expand_path("./bin", @deltoid_root)
    @deltoid_bin = File.expand_path("./deltoid", @deltoid_bin_dir)
    
    sphinx_yml_path = File.expand_path("./config/sphinx.yml", Rails.root)
    if File.exist?(sphinx_yml_path)
      sphinx_yml_data = ::YAML.load_file(sphinx_yml_path)
      active_config = sphinx_yml_data[@deltoid_env]
      if active_config && active_config['config_file']
        @deltoid_sphinx_config = File.expand_path(active_config['config_file'], Rails.root)
      end
    end
    
    @deltoid_sphinx_config ||= File.expand_path("./config/#{@deltoid_env}.sphinx.conf", Rails.root)
    @deltoid_memcached_yml = File.expand_path("./config/memcached.yml", Rails.root)
    
    @deltoid_log_directory = File.expand_path("./log", Rails.root)
    @deltoid_log_file = File.expand_path("./deltoid.#{@deltoid_env}.log", @deltoid_log_directory)
    @deltoid_pid_file = File.expand_path("./tmp/pids/deltoid.#{@deltoid_env}.pid", Rails.root)
    
    @deltoid_options = [
      "-e '#{@deltoid_env}'",
      "-l '#{@deltoid_log_file}'",
      "--config log_dir='#{@deltoid_log_directory}'",
      "--pidfile '#{@deltoid_pid_file}'",
      "-c '#{@deltoid_sphinx_config}'"
    ]
    
    if File.exist?(@deltoid_memcached_yml)
      @deltoid_options << "-m '#{@deltoid_memcached_yml}'"
    end
    
    if ENV['DELTOID_SCHEDULE'].present?
      @deltoid_options << "-S '#{ENV['DELTOID_SCHEDULE']}'"
    end
    
    @deltoid_run = "'#{@deltoid_bin}' #{@deltoid_options.join(" \\\n  ")}"
    @deltoid_start = "'#{@deltoid_bin}' start #{@deltoid_options.join(" \\\n  ")}"
    @deltoid_stop = "'#{@deltoid_bin}' stop #{@deltoid_options.join(" \\\n  ")}"
  end
  
  desc %{Displays the calculated deltoid daemon configuration values}
  task :env => "deltoid:init" do
    puts "deltoid_env:            #{@deltoid_env}"
    puts "deltoid_root:           #{@deltoid_root}"
    puts "deltoid_bin:            #{@deltoid_bin}"
    puts
    puts "deltoid_sphinx_config:  #{@deltoid_sphinx_config}"
    puts "deltoid_memcached_yml:  #{@deltoid_memcached_yml}"
    puts "deltoid_log_directory:  #{@deltoid_log_directory}"
    puts "deltoid_log_file:       #{@deltoid_log_file}"
    puts "deltoid_pid_file:       #{@deltoid_pid_file}"
    puts
    puts "Start command:"
    puts "  '#{@deltoid_bin}' start \\"
    puts "    #{@deltoid_options.join(" \\\n    ")}"
    puts
    puts "Stop command:"
    puts "  '#{@deltoid_bin}' stop \\"
    puts "    #{@deltoid_options.join(" \\\n    ")}"
  end
  
  desc %{Runs the deltoid daemon process in the foreground}
  task :run => "deltoid:init" do
    sh @deltoid_run
  end
  
  desc %{Starts the deltoid daemon process}
  task :start => "deltoid:init" do
    sh @deltoid_start
  end
  
  desc %{Stops the deltoid daemon process}
  task :stop => "deltoid:init" do
    sh @deltoid_stop
  end
  
  desc %{Restarts the deltoid daemon process}
  task :restart => %w[stop start]

  desc %{Sends a signal causing Deltoid to do a full reindex}
  task :reindex do
    pid = `ps ax`.grep(/deltoid/)[0].split[0].to_i
    Process.kill("USR1", pid)
  end

end

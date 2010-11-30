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
    
    @deltoid_sphinx_config = File.expand_path("./config/#{@deltoid_env}.sphinx.conf", Rails.root)
    @deltoid_memcached_yml = File.expand_path("./config/memcached.yml", Rails.root)
    
    @deltoid_log_directory = File.expand_path("./log", Rails.root)
    @deltoid_log_file = File.expand_path("./deltoid.#{@deltoid_env}.log", @deltoid_log_directory)
    @deltoid_pid_file = File.expand_path("./tmp/pids/deltoid.#{@deltoid_env}.pid", Rails.root)
    
    @deltoid_options = [
      "-e '#{@deltoid_env}'",
      "-l '#{@deltoid_log_file}'",
      "--config log_dir='#{@deltoid_log_directory}'",
      "--pidfile '#{@deltoid_pid_file}'",
      "-c '#{@deltoid_sphinx_config}'",
      "-m '#{@deltoid_memcached_yml}'"
    ]
    
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
  
  desc %{Starts the deltoid daemon process}
  task :start => "deltoid:init" do
    sh @deltoid_start
  end
  
  desc %{Stops the deltoid daemon process}
  task :stop => "deltoid:init" do
    sh @deltoid_stop
  end
  
end
# Argument handling for your daemon is configured here.
#
# You have access to two variables when this file is
# parsed. The first is +opts+, which is the object yielded from
# +OptionParser.new+, the second is +@options+ which is a standard
# Ruby hash that is later accessible through
# DaemonKit.arguments.options and can be used in your daemon process.

# Here is an example:
# opts.on('-f', '--foo FOO', 'Set foo') do |foo|
#  @options[:foo] = foo
# end

opts.on('-c', '--config CONFIG', 'Location of sphinx config file') do |sphinx_config|
  @options[:sphinx_config_file] = File.expand_path(sphinx_config)
end

opts.on('-s', '--sphinx-yml CONFIG', 'Location of sphinx yaml config file') do |sphinx_yaml|
  @options[:sphinx_yaml_file] = File.expand_path(sphinx_yaml)
end

opts.on('-m', '--memcached-yml CONFIG', 'Location of memcached YAML config file') do |memcached_yml|
  @options[:memcached_yml_file] = File.expand_path(memcached_yml)
end

opts.on('-S SCHEDULE', 'Cron-compatible schedule for performing full reindexes') do |schedule|
  @options[:main_indexing_schedule] = schedule
end

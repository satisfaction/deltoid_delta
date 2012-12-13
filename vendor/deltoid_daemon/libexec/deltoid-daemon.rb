require 'drb'

# Generated cron daemon

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
  config.trap('USR1') do
    DELTOID.reindex_main_indexes!(true)
  end

end

# Configuration documentation available at http://rufus.rubyforge.org/rufus-scheduler/
# An instance of the scheduler is available through
# DaemonKit::Cron.scheduler

# To make use of the EventMachine-powered scheduler, uncomment the
# line below *before* adding any schedules.
# DaemonKit::EM.run

# Some samples to get you going:

# Will call #regenerate_monthly_report in 3 days from starting up
#DaemonKit::Cron.scheduler.in("3d") do
#  regenerate_monthly_report()
#end
#
#DaemonKit::Cron.scheduler.every "10m10s" do
#  check_score(favourite_team) # every 10 minutes and 10 seconds
#end
#
#DaemonKit::Cron.scheduler.cron "0 22 * * 1-5" do
#  DaemonKit.logger.info "activating security system..."
#  activate_security_system()
#end
#
# Example error handling (NOTE: all exceptions in scheduled tasks are logged)
#DaemonKit::Cron.handle_exception do |job, exception|
#  DaemonKit.logger.error "Caught exception in job #{job.job_id}: '#{exception}'"
#end

DELTOID = Deltoid.new

# Check for executables on the path and log any that are missing
DELTOID.check_path_for_executables!

# Check that indexes are found in case the config is wrong
if DELTOID.delta_index_prefixes.length == 0
  DELTOID.logger.warn("Found 0 delta indexes in sphinx config: #{DELTOID.sphinx_config_file}")
else
  DELTOID.logger.info("Found #{DELTOID.delta_index_prefixes.length} delta indexes: #{DELTOID.delta_index_prefixes.map { |prefix| prefix + '_delta' }.join(', ')}")
end

DaemonKit::Cron.scheduler.every("1s") do
  DELTOID.reindex_stale_delta_indexes!
end

DaemonKit::Cron.scheduler.cron(DaemonKit.arguments.options[:main_indexing_schedule] || "0 8 * * *") do
  DELTOID.reindex_main_indexes!(true)
end

DRb.start_service 'druby://localhost:2250', DeltoidStatusServer.new(DELTOID)
DELTOID.logger.info("Stats server at #{DRb.uri}")
DRb.thread.join

# Run our 'cron' dameon, suspending the current thread
DaemonKit::Cron.run

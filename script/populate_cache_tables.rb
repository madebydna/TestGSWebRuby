# Hack to get around problem of running script
# via `rails runner` that also responds to the -h flag
ARGV << '-h' if ARGV.empty?

commands = CachePopulator::ArgumentParser.new.parse(ARGV)

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

# Start Logging
begin log = ScriptLogger.record_log_instance(commands); rescue; end

begin
  rows_updated = CachePopulator::Runner.populate_all_and_return_rows_changed(commands)
  begin log.finish_logging_session(1, "Successfully created/updated #{rows_updated} row(s)."); rescue; end
rescue => e
  begin log.finish_logging_session(0, e.message); rescue; end
  abort e.message
rescue SignalException
  begin log = log.finish_logging_session(0, "Process ended early. User manually cancelled process."); rescue; end
  abort
end

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting

puts "Successfully created/updated #{rows_updated} row(s)."
puts "Script populate_cache_tables.rb completed successfully and ran for #{elapsed} seconds"
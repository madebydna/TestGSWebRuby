require 'csv'

file = ARGV[0]

unless file.present? && File.exists?(file)
  abort <<~USAGE
  \n\nUSAGE: rails runner script/populate_cache_tables path/to/file

  Ex: rails runner script/populate_cache_tables rxxx_cache_updates.txt
  USAGE
end

log_params = []
CSV.foreach(file, headers: true, col_sep: "\t", quote_char: "\x00") do |line|
  hash = {}
  hash['type'] = line['type']
  hash['values'] = line['values']
  hash['cache_keys'] = line['cache_keys']
  log_params << hash
end

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
log = ScriptLogger.record_log_instance(log_params)
begin 
  rows_updated = CachePopulator::Runner.populate_all_and_return_rows_changed(file)
  log.finish_logging_session(1, "Successfully created/updated #{rows_updated} row(s).")
rescue => e
  log.finish_logging_session(0, e.message)
  abort e.message
end

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting

puts "Script populate_cache_tables.rb completed successfully and ran for #{elapsed} seconds"
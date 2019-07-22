file = ARGV[0]

unless file.present? && File.exists?(file)
    abort <<~USAGE
    \n\nUSAGE: rails runner script/populate_cache_tables path/to/file

    Ex: rails runner script/populate_cache_tables rxxx_cache_updates.txt
    USAGE
end

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

begin 
    CachePopulator::Runner.populate_all(file)
rescue => e
    abort e.message
end

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting

puts "Script populate_cache_tables.rb completed successfully and ran for #{elapsed} seconds"
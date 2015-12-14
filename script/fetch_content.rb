if ARGV.length != 2
  abort %q(
USAGE: rails runner script/fetch_content key url

Ex: rails runner script/fetch_content homepage_feature http://www.gs.org/gk/json-api/homepage_feature/)
  exit 1
end

begin
  content_fetcher = ExternalContentFetcher.new(ARGV[0], ARGV[1], true)
  rval = content_fetcher.fetch!
  exit (rval ? 0 : 1)
rescue => e
  puts "#{e.class} #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
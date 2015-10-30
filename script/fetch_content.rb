def fetch_content_usage
  abort %q(
USAGE: rails runner script/fetch_content key url

Ex: rails runner script/fetch_content homepage_feature http://www.gs.org/gk/json-api/homepage_feature/)
end

if ARGV.length != 2
  fetch_content_usage
  exit 1
end
content_fetcher = ExternalContentFetcher.new
rval = content_fetcher.fetch!(ARGV[0], ARGV[1])
exit (rval ? 0 : 1)
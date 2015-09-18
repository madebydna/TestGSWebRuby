def usage
  abort %q(
USAGE: rails runner script/fetch_content key url

Ex: rails runner script/populate_school_cache_table homepage_feature http://www.gs.org/gk/json-api/homepage_feature/)
end

if ARGV.length != 2
  usage
  exit 1
end
content_fetcher = ExternalContentFetcher.new
rval = content_fetcher.fetch!(ARGV[0], ARGV[1])
usage unless rval

exit (rval ? 0 : 1)
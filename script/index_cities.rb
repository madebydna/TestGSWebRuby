# frozen_string_literal: true

require 'optparse'

script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [script_args]"
  opts.on("-u SOLR_URL", "--solr-url SOLR_URL", String, 'URL of Solr endpoint including core. E.g. http://localhost:8983/solr/main/') { |u| script_args[:solr_url] = u }
  opts.on("-d", "--delete DELETE", String, 'delete documents matching specified criteria') { |b| script_args[:delete] = b }
  opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
end.parse!

solr_url = script_args[:solr_url] || ENV_GLOBAL['solr.rw.server.url']

indexer = Search::SolrIndexer.with_rsolr_client(solr_url)
if script_args[:delete]
  indexer.delete_all_by_type(Search::CityDocument)
else
  documents = Search::CityDocumentFactory.new.documents
  indexer.index(documents)
end
indexer.commit
indexer.optimize

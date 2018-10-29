# frozen_string_literal: true

require 'optparse'

ARGV << '-h' if ARGV.empty?
script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [script_args]"
  opts.on("-u SOLR_URL", "--solr-url SOLR_URL", String, 'URL of Solr endpoint including core. E.g. http://localhost:8983/solr/main/') { |u| script_args[:solr_url] = u }
  opts.on("-s STATES", "--states STATES", String, 'comma separated states to index') { |s| script_args[:states] = s }
  opts.on("-i IDS", "--ids IDS", String, 'comma separated IDs to index') { |i| script_args[:ids] = i }
  opts.on("-d", "--delete DELETE", String, 'delete documents matching specified criteria') { |b| script_args[:delete] = b }
  opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
end.parse!

states = script_args[:states]&.split(',')
ids = script_args[:ids]&.split(',')

indexer = 
  if script_args[:solr_url]
    Solr::Indexer.with_solr_url(script_args[:solr_url])
  else
    Solr::Indexer.with_rw_client
  end

if script_args[:delete]
  indexer.delete_all_by_type(Solr::DistrictDocument)
else
  documents = Search::DistrictDocumentFactory.new(states: states, ids: ids).documents
  indexer.index(documents)
end
indexer.commit
indexer.optimize

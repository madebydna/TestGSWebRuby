# frozen_string_literal: true

require 'optparse'

ARGV << '-h' if ARGV.empty?
script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [script_args]"
  opts.on("-l HOST", "--host HOST", String, 'Hostname of the solr server. Defaults to localhost') { |h| script_args[:host] = h }
  opts.on("-p PORT", "--port PORT", String, 'Port of the solr server. Defaults to 8983') { |h| script_args[:port] = p }
  opts.on("-c CORE", "--core CORE", String, 'Name of the of Solr core to index to. Usually [main|prep]. Default to prep') { |c| script_args[:core] = c }
  opts.on("-s STATES", "--states STATES", String, 'comma separated states to index') { |s| script_args[:states] = s }
  opts.on("-i IDS", "--ids IDS", String, 'comma separated IDs to index') { |i| script_args[:ids] = i }
  opts.on("-d", "--delete DELETE", String, 'delete documents matching specified criteria') { |b| script_args[:delete] = b }
  opts.on("-w", "--[no-]wipe", 'Whether to wipe the core first. Defaults to false') { |b| script_args[:wipe] = b }
  opts.on("-x", "--[no-]swap", 'Whether to swap the main and prep cores after done indexing. Defaults to false') { |b| script_args[:swap] = b }
  opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
end.parse!

states = (script_args[:states] || States.abbreviations.join(',')).split(',')
ids = script_args[:ids]&.split(',')
host = script_args[:host] || 'localhost'
port = script_args[:port] || 8983
core = script_args[:core] || 'prep'
should_swap_cores = script_args.has_key?(:swap) ? script_args[:swap] : false
should_wipe_core = script_args.has_key?(:wipe) ? script_args[:wipe] : false

solr_url =  if script_args.has_key?(:host)
              "http://#{host}:#{port}/solr/#{core}/"
            else
              ENV_GLOBAL['solr.rw.server.url']
            end

# Start logging
begin log = ScriptLogger.record_log_instance(script_args); rescue;end

begin
  indexer = 
    if script_args.has_key?(:host)
      Solr::Indexer.with_solr_url(solr_url)
    else
      Solr::Indexer.with_rw_client
    end
            
  indexer.delete_all if should_wipe_core

  if script_args[:delete]
    indexer.delete_all_by_type(Solr::DistrictDocument)
  else
    documents = Search::DistrictDocumentFactory.new(states: states, ids: ids).documents
    num_of_indexed_docs = indexer.index(documents)
  end

  indexer.commit
  indexer.optimize

  begin log.finish_logging_session(1, "Finished indexing #{num_of_indexed_docs} documents"); rescue;end
  puts "Finished indexing #{num_of_indexed_docs} documents"

rescue => e
  begin log.finish_logging_session(0, e); rescue;end
  raise
rescue SignalException
  begin log = log.finish_logging_session(0, "Process ended early. User manually cancelled process."); rescue;end
  abort
end

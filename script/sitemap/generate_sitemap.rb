# frozen_string_literal: true

require_relative('sitemap_generator')

log = ScriptLogger.record_log_instance rescue nil

begin
  SitemapGenerator.new.generate
  log.finish_logging_session(1, "Finished generating sitemap") rescue nil
rescue => e
  log.finish_logging_session(0, e) rescue nil
  raise
rescue SignalException
  log.finish_logging_session(0, "Process ended early. User manually cancelled process.") rescue nil
  abort
end


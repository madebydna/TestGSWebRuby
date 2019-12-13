# frozen_string_literal: true

require_relative('sitemap_generator')

output_dir = ARGV[0] || ENV['PWD']

log = ScriptLogger.record_log_instance(output_dir: output_dir) rescue nil

Rails.application.routes.default_url_options[:protocol] = 'https'

begin
  SitemapGenerator.new.generate(output_dir)
  log.finish_logging_session(1, "Finished generating sitemap") rescue nil
rescue => e
  log.finish_logging_session(0, e) rescue nil
  raise
rescue SignalException
  log.finish_logging_session(0, "Process ended early. User manually cancelled process.") rescue nil
  abort
end


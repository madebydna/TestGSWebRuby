require 'net/http'
require 'uri'

class ExternalContentFetcher
  attr_reader :key, :uri, :use_stdout

  def initialize(key, url, use_stdout=false)
    raise "ExternalContentFetcher requires a key and URL. Was provided key='#{key}', url='#{url}'" unless key.present? && url.present?
    @key = key
    begin
      @uri = URI.parse(URI.encode(url))
    rescue => e
      return error("Provided invalid URI: #{url}", e)
    end
    @use_stdout = use_stdout
  end

  def fetch!
    return false unless uri_valid?

    body = get_response_as_string
    return false unless body.present?

    save_content!(body)
  end

  protected

  def save_content!(body)
    begin
      external_content = ExternalContent.find_or_initialize_by(content_key: @key)

      return error("Error updating attributes on #{external_content}", nil, {key: @key, body: body}) unless
        external_content.update_attributes!(
          content: body,
          updated: Time.now
        )
      true
    rescue => e
      error('Error saving to external_content', e, {key: @key, body: body})
      false
    end
  end

  def error(msg, exception=nil, vars=nil)
    GSLogger.error(:external_content_fetcher, exception, {message: msg, vars: vars})
    if @use_stdout
      log_msg = msg
      if vars
        log_msg << " (#{vars.to_s})"
      end
      if exception
        log_msg << ": #{exception.class} #{exception.message}"
        log_msg << "\n" << exception.backtrace.join("\n")
      end
      puts log_msg
    end
    false
  end

  def get_response_as_string
    begin
      response = make_request
    rescue => e
      error('Error making request', e, {url: @uri.to_s})
      return nil
    end

    error("Error: empty response from #{@uri.to_s}") and (return nil) unless response.present? && response.body.present?
    error("Error: #{response.code} response code from #{@uri.to_s}, expected 200") and (return nil) unless response.code == '200'

    response.body
  end

  def make_request
    Net::HTTP.new(@uri.host, @uri.port).request(Net::HTTP::Get.new(@uri.request_uri))
  end

  def uri_valid?
    return error('Provided invalid URI: Empty')                        unless @uri.present?
    return error("Provided invalid URI: #{@uri.to_s}: Missing scheme") unless @uri.scheme.present?
    return error("Provided invalid URI: #{@uri.to_s}: Invalid scheme") unless @uri.scheme == 'http' || @uri.scheme == 'https'
    return error("Provided invalid URI: #{@uri.to_s}: Missing host")   unless @uri.host.present?
    true
  end
end
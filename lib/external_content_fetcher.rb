require 'net/http'
require 'uri'

class ExternalContentFetcher
  def fetch!(key, url_s)
    return error("ExternalContentFetcher requires a key and URL. Was provided key='#{key}', url='#{url_s}'") unless key.present? && url_s.present?
    begin
      uri = URI.parse(URI.encode(url_s))
    rescue
      return error("Provided invalid URI: #{url_s}")
    end
    return error("Provided invalid URI: #{url_s}") unless uri_valid?(uri)

    body = get_response_as_string(uri)
    return error('Failed to retrieve body') unless body.present?

    save_content!(key, body)
  end

  protected

  def save_content!(key, body)
    begin
      external_content = ExternalContent.find_or_initialize_by(content_key: key)

      return error("Error updating attributes on #{external_content}", nil, {key: key, body: body}) unless
        external_content.update_attributes!(
          content: body,
          updated: Time.now
      )
      true
    rescue => e
      error(nil, e, {key: key, body: body})
      false
    end
  end

  def error(msg, exception=nil, vars=nil)
    GSLogger.error(:external_content_fetcher, exception, {message: msg, vars: vars})
    false
  end

  def get_response_as_string(uri)
    begin
      response = make_request(uri)
    rescue => e
      error(nil, e)
    end
    if response.present? && response.body.present? && response.code == '200'
      response.body
    else
      nil
    end
  end

  def make_request(uri)
    Net::HTTP.new(uri.host, uri.port).request(Net::HTTP::Get.new(uri.request_uri))
  end

  def uri_valid?(uri)
    uri.present? && uri.scheme.present? && uri.host.present? && (uri.scheme == 'http' || uri.scheme == 'https')
  end
end
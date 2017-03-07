class UrlUtils
  def self.valid_redirect_uri?(uri)
    return false unless uri.present?
    uri_relative?(uri) || uri_absolute_to_gs_org?(uri) || uri_absolute_to_localhost?(uri)
  end

  private

  def self.uri_relative?(uri)
    uri.first == '/'
  end

  def self.uri_absolute_to_gs_org?(uri)
    match_gs_org_regex = /^http(?:s)?:\/\/(?:[^\/]+\.)?greatschools\.org(?:\/|:|\?|$).*/
    match_gs_org_regex.match(uri)
  end

  def self.uri_absolute_to_localhost?(uri)
    match_localhost_regex = /^http:\/\/localhost(?:\/|:|\?|$).*/
    match_localhost_regex.match(uri)
  end
end
class InterstitialAdController < ApplicationController

  layout "no_header_and_footer"

  def show
    gon.pagename = "Interstitial Ad"
    set_meta_tags(title: "Interstiail Ad",
                  refresh: "20;#{pass_through_URI}",
                  robots: 'noindex, nofollow, noarchive')
  end

  private

  def pass_through_URI
    uri = params[:passThroughURI]
    if uri.present?
      uri = URI.decode(uri)
      uri = whitelist_uri(uri)
    else
      uri = ""
    end
    URI.encode(uri)
  end

  def whitelist_uri(uri)
    if !valid_uri?(uri)
      return "/"
    else
      return uri
    end
  end

  def valid_uri?(uri)
    relative?(uri) || absolute_to_localhost?(uri) || absolute_to_gs_org?(uri)
  end

  def relative?(uri)
    uri.first == "/"
  end

  def absolute_to_gs_org?(uri)
    match_gs_org_regex = /^http(?:s)?:\/\/(?:[^\/]+\.)?greatschools\.org(?:\/|:|$).*/
    match_gs_org_regex.match(uri)
  end

  def absolute_to_localhost?(uri)
    match_localhost_regex = /^http:\/\/localhost(?:\/|:|$).*/
    match_localhost_regex.match(uri)
  end
end

class InterstitialAdController < ApplicationController

  layout "no_header_and_footer"

  def show
    gon.pagename = "Interstitial Ad"
    set_meta_tags(title: "Interstitial Ad",
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
    return uri if UrlUtils.valid_redirect_uri?(uri)
    '/'
  end
end

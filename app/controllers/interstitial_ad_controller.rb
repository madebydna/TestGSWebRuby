class InterstitialAdController < ApplicationController

  layout "application"

  def show
    gon.pagename = "Interstitial Ad"
    set_meta_tags(refresh: "20;#{pass_through_URI}",
                  robots: 'noindex, nofollow, noarchive')
  end

  private

  def pass_through_URI
    uri = params[:passThroughURI]
    if uri.present?
      uri = URI.decode(uri)
    else
      uri = ""
    end
    uri
  end
end

class InterstitialAdController < ApplicationController

  layout "application"

  def show
    gon.pagename = "Interstitial Ad"
  end

end

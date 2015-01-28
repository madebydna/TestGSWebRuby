class SchoolProfileQualityController < SchoolProfileController
  protect_from_forgery

  include AdvertisingHelper

  layout 'application'

  def quality
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Quality'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

end
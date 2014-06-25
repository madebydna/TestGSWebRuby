class SchoolProfileOverviewController < SchoolProfileController
  protect_from_forgery

  include OmnitureConcerns
  include AdvertisingHelper

  layout 'application'

  def overview
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Overview'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

end
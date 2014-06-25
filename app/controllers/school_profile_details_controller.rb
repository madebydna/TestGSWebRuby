class SchoolProfileDetailsController < SchoolProfileController
  protect_from_forgery

  include OmnitureConcerns
  include AdvertisingHelper

  layout 'application'

  def details
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Details'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

end
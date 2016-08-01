class SchoolProfileDetailsController < DeprecatedSchoolProfileController
  protect_from_forgery


  layout 'deprecated_application'

  def details
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Details'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

end

class SchoolProfileQualityController < DeprecatedSchoolProfileController
  protect_from_forgery

  layout 'deprecated_application'

  def quality
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Quality'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

end

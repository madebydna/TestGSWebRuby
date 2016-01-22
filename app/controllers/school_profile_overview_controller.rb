class SchoolProfileOverviewController < SchoolProfileController
  protect_from_forgery

  layout 'application'

  def overview
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Overview'
    gon.contact_map ||= static_google_maps
    set_omniture_data(gon.omniture_pagename)
    add_number_of_school_reviews_to_gtm_data_layer
    @canonical_url = school_url(@school)
  end

  protected

  def add_number_of_school_reviews_to_gtm_data_layer
    set_gtm_data_layer_attribute('number_of_school_reviews', school_reviews.number_of_reviews_with_comments)
  end

end

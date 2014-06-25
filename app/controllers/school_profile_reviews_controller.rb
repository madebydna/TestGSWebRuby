class SchoolProfileReviewsController < SchoolProfileController
  protect_from_forgery

  include OmnitureConcerns
  include AdvertisingHelper

  layout 'application'

  def reviews
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Reviews'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_reviews_url(@school)
    @canonical_url = school_url(@school)

    @school_reviews = @school.reviews_filter quantity_to_return: 10

    @review_offset = 0
    @review_limit = 10
  end

end
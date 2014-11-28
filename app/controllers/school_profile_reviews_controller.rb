class SchoolProfileReviewsController < SchoolProfileController
  protect_from_forgery

  include AdvertisingHelper

  layout 'application'

  def reviews
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Reviews'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_reviews_url(@school)
    @canonical_url = school_url(@school)

    @school_reviews = @school.reviews_filter quantity_to_return: 10

    @school_reviews_helpful_counts = HelpfulReview.helpful_counts(@school_reviews)
    @school_principal_review = @school.principal_review

    @review_offset = 0
    @review_limit = 10

    @facebook_comments_show = property_state_on?(@facebook_comments_prop, @state[:short])
  end

end
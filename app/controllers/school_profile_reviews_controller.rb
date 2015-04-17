class SchoolProfileReviewsController < SchoolProfileController
  protect_from_forgery

  include AdvertisingHelper
  include DeferredActionConcerns
  include ReviewControllerConcerns

  layout 'application'


  def reviews
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Reviews'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_reviews_url(@school)
    @canonical_url = school_url(@school)

    # @school_reviews = @school.reviews_filter quantity_to_return: 10
    @school_reviews = SchoolProfileReviewsDecorator.decorate(SchoolReviews.new(@school), view_context)

    # @school_reviews_helpful_counts = HelpfulReview.helpful_counts(@school_reviews)
    @school_principal_review = @school.principal_review

    @review_offset = 0
    @review_limit = 10

    @facebook_comments_show = property_state_on?(@facebook_comments_prop, @state[:short])
  end

  def create
    json_message = {}
    status = :ok

    if logged_in?
      review, errors = build_review_params(review_params).save_new_review
      if errors
        status = :unprocessable_entity
        json_message = errors
      else
        status = :created
      end
    else
      save_deferred_action :save_review_deferred, review_params
      json_message[:redirect_url] = join_url
      status = :ok
    end

    respond_to do |format|
      format.json { render json: json_message, status: status }
    end
  end

private

  def review_params
    params.require(:review).permit(:school_id, :state, :review_question_id, :comment,
                                   review_answers_attributes:[ :value, :review_id])
  end

end
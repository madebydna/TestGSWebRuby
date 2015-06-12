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
    @canonical_url = school_url(@school)
    @reviews_page_size = 10
    @first_topic_id_to_show = first_topic_id_to_show
  end

  # Must be called after the init_page before_action, since that sets the @school_user instance variable
  def first_topic_id_to_show
    if @school_user
      @school_user.first_unanswered_topic.try(:id)
    else
      ReviewTopic.find_id_by_name(ReviewTopic::HONESTY)
    end
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
    params.
      require(:review).
      permit(
        :school_id,
        :state,
        :review_question_id,
        :comment,
        answers_attributes:
          [
            :review_id,
            :answer_value
          ]
      )
  end

end
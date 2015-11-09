class SchoolProfileReviewsController < SchoolProfileController
  protect_from_forgery

  include AdvertisingHelper
  include DeferredActionConcerns
  include ReviewControllerConcerns

  layout 'application'

  def reviews
    @school_reviews.add_number_of_votes_method_to_each
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Reviews'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = canonical_url
    @reviews_page_size = 10
    @first_topic_id_to_show = first_topic_id_to_show
    @show_role_question = show_role_question?
  end

  # Must be called after the init_page before_action, since that sets the @school_user instance variable
  def first_topic_id_to_show
    if @school_user
      @school_user.first_unanswered_topic.try(:id)
    else
      ReviewTopic.find_id_by_name(ReviewTopic::OVERALL)
    end
  end

  def show_role_question?
    current_user && school_user.reviews.present? && school_user.unknown?
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
        json_message = {
            user_type: school_user.user_type
        }
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

# Based on SEO consultant's advice, reviews tab will rel canonical to overview
# tab as when the overview is diaplaying all the textual reviews.
# The review tab will rel canonical to itself when there is at least one 
# review that is not shown on overview

def canonical_url
    rel_canonical_to_overview? ? school_url(@school) : school_reviews_url(@school)
  end

  def rel_canonical_to_overview?
    @school_reviews.number_of_reviews_with_comments <= NUMBER_OF_REVIEWS_ON_OVERVIEW
  end

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

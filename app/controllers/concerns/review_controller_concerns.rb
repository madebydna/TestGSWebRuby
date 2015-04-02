module ReviewControllerConcerns
  extend ActiveSupport::Concern
  include ApplicationHelper
  include UpdateQueueConcerns

  protected

  class ReviewParams
    def initialize(params, user)
      raise(ArgumentError, "Must provide params hash") unless params && params.is_a?(Hash)
      raise(ArgumentError, "Must provide school_id and state") unless params[:school_id] && params[:state]

      @user = user
      @params = params
    end

    def school
      @school ||= School.find_by_state_and_id(state, school_id)
    end

    def state
      @params[:state]
    end

    def school_id
      @params[:school_id]
    end

    def save_new_review
      handle_save(new_review)
    end

    def update_existing_review
      review = existing_review
      review.attributes = review_attributes
      handle_save(review)
    end

    def handle_save(review)
      error = nil
      unless review.save
        # safe even if no errors
        error = review.errors.full_messages.first
        review = nil
      end
      return review, error
    end

    def review_attributes
      @params.merge(
          school: school,
          user: @user
      )
    end

    # TODO: Figure this out
    def existing_review
      @existing_review ||= user.reviews_for_school(school: school).first
    end

    def new_review
      Review.new(review_attributes)
    end
  end

  def build_review_params(params)
    ReviewParams.new(params, current_user)
  end

  def save_review_and_redirect(params)
    review, error = build_review_params(params).save_new_review

    if error.nil?
      if review.active?
        flash_notice t('actions.review.activated')
        #set omniture events and props after the review has been published.
        set_omniture_events_in_cookie(['review_updates_mss_end_event'])
        set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'PublishReview'})
      else
        flash_notice t('actions.review.pending_moderation')
      end
      redirect_to reviews_page_for_last_school
    else
      flash_error error
      redirect_to review_form_for_last_school
    end
  end

  def report_review_and_redirect(params)

    if logged_in?
      begin
        review_id = params[:reported_entity_id]
        reason = params[:reason]

        review = SchoolRating.find review_id rescue nil
        if review
          reported_entity = ReportedEntity.from_review review, reason
          reported_entity.reporter_id = current_user.id
          if reported_entity.save
            flash_notice t('actions.report_review.reported')
          else
            flash_error t('actions.generic_error')
          end
        else
          flash_error t('actions.generic_error')
        end
      rescue => e
        Rails.logger.debug e
        flash_error t('actions.generic_error')
      end
    end

    redirect_to reviews_page_for_last_school
  end

end

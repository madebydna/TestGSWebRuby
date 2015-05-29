module ReviewControllerConcerns
  extend ActiveSupport::Concern
  include ApplicationHelper
  include UpdateQueueConcerns

  protected

  class ReviewParams
    attr_reader :params, :user
    def initialize(params, user)
      @user = user
      @params = params
    end

    def errors
      result = []
      result << 'No valid parameters supplied' unless params && params.is_a?(Hash)
      result << 'Must provide school id' unless school_id
      result << 'Must provide school state' unless state
      result << 'Specified school was not found' unless school
      result
    end

    def school
      @school ||= School.find_by_state_and_id(state, school_id)
    end

    def state
      params[:state]
    end

    def school_id
      params[:school_id]
    end

    def save_new_review
      review = Review.new
      old_review = existing_review
      if old_review
        old_review.deactivate
        _, errors = handle_save(old_review)
        return old_review, errors if errors.present?
      end
      review.attributes = review_attributes
      handle_save(review)
    end

    def update_existing_review
      review = existing_review
      review.attributes = review_attributes
      handle_save(review)
    end

    def handle_save(review)
      errors = []
      errors += self.errors.dup
      return nil, errors if errors.any?

      unless review.save
        errors += review.errors.full_messages
        review = nil
      end
      errors = nil if errors.empty?
      return review, errors
    end

    def review_attributes
      params.merge(user:user,school: school )
    end

    # TODO: Figure this out
    def existing_review
      @existing_review ||= user.active_reviews_for_school(school: school).first
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
        if current_user.provisional?
          flash_notice t('actions.review.pending_email_verification')
        else
          flash_notice t('actions.review.pending_moderation')
        end
      end
      redirect_to reviews_page_for_last_school
    else
      flash_error error
      redirect_to reviews_page_for_last_school
    end
  end

  def flag_review_and_redirect(params)

    if logged_in?
      begin
        review_id = params[:review_id]
        comment = params[:comment]

        review = Review.find review_id rescue nil
        if review
          review_flag = review.build_review_flag(comment, ReviewFlag::USER_REPORTED)
          review_flag.user = current_user
          if review_flag.save
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

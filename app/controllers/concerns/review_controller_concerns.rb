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
      result << 'Must provide school id' unless params[:review][:school_id]
      result << 'Must provide school state' unless params[:review][:state]
      result << 'Specified school was not found' unless school
      result
    end

    def school
      @school ||= School.find_by_state_and_id(state, school_id)
    end

    def state
      @params[:review][:state]
    end

    def school_id
      @params[:review][:school_id]
    end

    def save_new_review
      review = Review.new
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
      # @params.except(:state).except(:school_id).merge(
      #     school: school,
      #     user: @user
      # )
      @params[:review].merge(user:user,school: school )
    end

    # TODO: Figure this out
    def existing_review
      @existing_review ||= user.reviews_for_school(school: school).first
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
      redirect_to reviews_page_for_last_school
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

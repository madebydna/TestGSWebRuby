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

    def school_user
      @school_user ||= SchoolUser.build_unknown_school_user(school, user)
    end

    def save_new_review
      review = Review.new
      existing_review, errors = deactivate_existing_review
      return existing_review, errors if errors.present?
      review.attributes = review_attributes
      handle_save(review)
    end

    def deactivate_existing_review
      old_review = existing_review
      return nil, nil unless old_review

      old_review.deactivate
      handle_save(old_review)
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
      params[:comment].gsub!("\r\n", "\n") if params[:comment]
      params.merge(user:user, school: school)
    end

    def existing_review
      @existing_review ||= school_user.find_active_review_by_question_id(params[:review_question_id].to_i)
    end
  end

  def build_review_params(params)
    ReviewParams.new(params, current_user)
  end

  def save_review(params)
    review, error = build_review_params(params).save_new_review

    if error.nil?
      if review.active?
        flash_success t('actions.review.activated')
        #set omniture events and props after the review has been published.
        set_omniture_events_in_cookie(['review_updates_mss_end_event'])
        set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'PublishReview'})
      else
        if current_user.provisional?
          flash_notice t('actions.review.pending_email_verification')
          delete_account_pending_email_verification_flash_notice
        else
          flash_notice t('actions.review.pending_moderation')
        end
      end
    else
      flash_error error
    end
  end

  def delete_account_pending_email_verification_flash_notice
    #   removes the provisional flash message set when user signs in user
    #   and signin controller
    pending_email_verification_msg = t('actions.account.pending_email_verification')
    flash[:notice].delete_if {|msg| msg == pending_email_verification_msg }
  end

  def flag_review_and_redirect(params)

    if logged_in?
      begin
        review_id = params[:review_id]
        comment = params[:comment]

        review = Review.find review_id rescue nil
        if review
          existing_flag = ReviewFlag.find_by(member_id: current_user.id, review_id: review.id, active: 1)
          if existing_flag.present?
            review_flag = existing_flag
            review_flag.comment = comment
            review_flag.created = Time.now
          else
            review_flag = review.build_review_flag(comment, ReviewFlag::USER_REPORTED)
            review_flag.user = current_user
          end
          if review_flag.save
            if request.xhr?
              render json: {}, status: :ok
            else
              flash_success t('actions.report_review.reported')
            end
          else
            GSLogger.error(:reviews, nil, vars: review_flag.attributes, message: "Unable to save ReviewFlag: #{review_flag.errors.first}")
            if request.xhr?
              render json: {}, status: :internal_server_error
            else
              flash_error t('actions.generic_error')
            end
          end
        else
          if request.xhr?
            render json: {}, status: :internal_server_error
          else
            flash_error t('actions.generic_error')
          end
        end
      rescue => e
        GSLogger.error(:reviews, e, message: 'Unable to save ReviewFlag')
        if request.xhr?
          render json: {}, status: :internal_server_error
        else
          flash_error t('actions.generic_error')
        end
      end
    end

    unless request.xhr?
      redirect_to reviews_page_for_last_school
    end
  end

end

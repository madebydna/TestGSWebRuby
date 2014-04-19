module ReviewControllerConcerns
  extend ActiveSupport::Concern
  include OmnitureConcerns
  include ApplicationHelper

  protected

  def save_review(current_user, review_params)
    review, error = update_existing_review(current_user, review_params)
    return review, error if review || error

    begin
      review = review_from_params(review_params)
      review.user = current_user

      unless review.save
        # safe even if no errors
        error = review.errors.full_messages.first
        review = nil
      end
    rescue => e
      Rails.logger.debug e
      error = 'Something went wrong while trying to save the review.'
    end

    return review, error
  end

  def update_existing_review(current_user, review_params)
    existing_review, error = nil

    begin
      existing_review = current_user.reviews_for_school(
        state: review_params[:state], 
        school_id: review_params[:school_id]
      ).first

      if existing_review
        review_from_params = review_from_params(review_params)
        review_from_params.user = current_user
        unless existing_review.update_attributes(review_from_params.attributes)
          # safe even if no errors
          error = existing_review.errors.full_messages.first
          existing_review = nil
        end
      end
    rescue => e
      Rails.logger.debug e
      error = 'Something went wrong while trying to save the review.'
    end

    return existing_review, error
  end

  def save_review_and_redirect(review_params)
    review, error = save_review(current_user, review_params)

    if error.nil?
      if review.published?
        flash_notice t('actions.review.activated')
        #set omniture events and props after the review has been published.
        set_omniture_events_in_session(['review_updates_mss_end_event'])
        set_omniture_sprops_in_session({'custom_completion_sprop' => 'PublishReview'})
      elsif review.who == 'student'
        flash_notice t('actions.review.pending_moderation')
      else
        flash_notice t('actions.review.pending_email_verification')
      end
      redirect_to reviews_page_for_last_school
    else
      flash_error error
      redirect_to review_form_for_last_school
    end
  end

  def review_from_params(review_params)
    if review_params && review_params.is_a?(Hash) &&
      review_params[:school_id] && review_params[:state]

      school = School.find_by_state_and_id(
        review_params[:state], 
        review_params[:school_id]
      )

      review = SchoolRating.new
      if school.preschool?
        review.p_overall = review_params[:overall]
      else
        review.quality = review_params[:overall]
      end
      review.state = review_params[:state]
      review.school = school
      review.comments = review_params[:review_text]
      review.affiliation = review_params[:affiliation]
      review.school_type = school.type
      review.posted = Time.now.to_s
      review.ip = remote_ip
      review
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
          reported_entity.save!
          flash_notice t('actions.report_review.reported')
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

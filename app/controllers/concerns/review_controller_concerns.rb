module ReviewControllerConcerns
  extend ActiveSupport::Concern
  include OmnitureConcerns

  def save_review(current_user, review_params)
    error = nil

    if review_params.nil?
      return nil, 'Tried to create a review, but provided params is nil'
    end

    review_from_params = review_from_params(review_params)

    if review_from_params.nil?
      return nil, "Could not create review from params. Most likely malformed or missing params. Params: #{review_params.to_s}"
    end

    review_from_params.user = current_user
    existing_review = SchoolRating.where(review_from_params.uniqueness_attributes).first
    review = existing_review || review_from_params

    if existing_review
      review.update_attributes(review_from_params.attributes)
    end

    begin
      review.save!
    rescue
      error = review.errors.messages.first[1].first
    end

    return review, error
  end

  def save_review_and_redirect(review_params)
    review, error = save_review(current_user, review_params)

    if error.nil?
      if review.published?
        flash_notice t('actions.review.activated')
        #set omniture events and props after the review has been published.
        set_omniture_events_in_session(['review_updates_mss_event'])
        set_omniture_sprops_in_session({'custom_completion_sprop' => 'PublishReview'})
      elsif review.who = 'student'
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
    if review_params && review_params.is_a?(Hash) && review_params[:school_id] && review_params[:state]
      begin
        school = School.on_db(review_params[:state].downcase.to_sym).find(review_params[:school_id])

        review = SchoolRating.new
        review.state = review_params[:state]
        review.school = school
        review.comments = review_params[:review_text]
        review.overall = review_params[:overall]
        review.affiliation = review_params[:affiliation]
        review.school_type = school.type
        review.posted = Time.now.to_s
        review.ip = remote_ip
        review
      rescue => e
        Rails.logger.debug "Could not find school that review was for: School #{review_params[:school_id]}. Error: #{e.message}"
      end
    end
  end

end

module ReviewControllerConcerns
  extend ActiveSupport::Concern

  def save_review(current_user, review_params)
    error = nil
    review_from_params = review_from_params(review_params)
    review_from_params.member_id = current_user.id
    existing_review = SchoolRating.where(review_from_params.uniqueness_attributes).first
    review = existing_review || review_from_params

    if existing_review
      review.update_attributes(review_from_params.attributes)
    end

    # TODO: lots of work to support saving review. check for other statuses, alert word filter, etc
    if current_user.provisional?
      review.status = 'pp'
    else
      review.status = 'p'
    end

    begin
      review.id = 99999 # TODO: review code
      #review.save!
    rescue
      error = review.errors.messages.first[1].first
    end

    return review, error
  end

  def review_from_params(review_params)
    school = School.on_db(review_params[:state].downcase.to_sym).find(review_params[:school_id])

    review = SchoolRating.new
    review.state = review_params[:state]
    review.school_id = review_params[:school_id]
    review.comments = review_params[:review_text]
    review.school_type = school.type
    review
  end

  def successful_save_redirect(review_params)
    state = review_params[:state]
    school_id = review_params[:school_id]
    school = School.on_db(state.downcase.to_sym).find(school_id)
    school_url(school_params(school))
  end

  def save_review_params
    cookies[:review] = params[:school_rating].to_json
  end

  def get_review_params
    string = cookies[:review]
    if string
      params = JSON.parse string
      if params
        params.symbolize_keys!
      end
      return params
    end
  end

  def clear_review_params
    cookies.delete(:review)
  end

end

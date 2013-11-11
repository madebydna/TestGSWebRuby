module ReviewControllerConcerns
  extend ActiveSupport::Concern

  def save_review(review_params)
    review = review_from_params(review_params)
    existing_review = SchoolRating.where(review.uniqueness_attributes).first
    if existing_review
      existing_review.update_attributes(review.attributes)
      existing_review.save!
    else
      review.save!
    end
  end

  def review_from_params(review_params)
    review = SchoolRating.new
    review.member_id = current_user.id
    review.state = review_params[:state]
    review.school_id = review_params[:school_id]
    review.comments = review_params[:review_text]
    review
  end

  def successful_save_redirect(review_params)
    state = review_params[:state]
    school_id = review_params[:school_id]
    school = School.on_db(state.downcase.to_sym).find(school_id)
    school_path(school_params(school))
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

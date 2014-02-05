module SessionConcerns
  extend ActiveSupport::Concern
  include UrlHelper

  STORED_LOCATION_EXPIRATION = 15.minutes

  def set_last_school_visited
    if @school.present?
      params = { id: @school.id, state: @school.state }
      write_cookie_value :last_school, params
    end
  end
  def last_school_visited
    params = self.last_school_visited_params
    id = params[:id]
    state = params[:state]
    @last_school ||= School.on_db(state.downcase.to_sym).find(id) rescue nil
  end
  def last_school_visited_params
    read_cookie_value :last_school
  end
  def reviews_page_for_last_school
    params = last_school_visited_params
    school_reviews_url(last_school_visited) if params.present?
  end
  def overview_page_for_last_school
    params = last_school_visited_params
    school_url(last_school_visited) if params.present?
  end
  def review_form_for_last_school
    params = last_school_visited_params
    new_school_rating_url(last_school_visited) if params.present?
  end

  def user_profile_or_home
    logged_in? ? '/account/' : '/index.page'
  end

  def store_location(uri = original_url, overwrite = true)
    write_cookie_value :history, uri, :last_page, overwrite
  end

  def stored_location
    read_cookie_value :history, :last_page
  end

  def has_stored_location?
    stored_location.present?
  end

  # Redirect to the URI stored by the most recent store_location call or to the passed default.
  def redirect_back_or_default(default = request.referrer || original_url) # TODO: change default
    stored_location = read_cookie_value :return_to
    if stored_location.present? && stored_location.include?('://')
      redirect_to stored_location
    else
      redirect_to default
    end
    delete_cookie :return_to
  end

  # upon successful authentication, handle whatever user was trying to do previously
  # save pending form posts and/or redirect user
  def process_pending_actions(user)
    review_params = get_review_params
    if review_params
      review, error = save_review(user, review_params)
      if error.nil?
        clear_review_params
        if review.published?
          flash_notice t('actions.review.activated')
        else
          flash_notice t('actions.review.pending_email_verification')
        end
        redirect_back_or_default
      else
        flash_error error
        redirect_back_or_default
      end
    else
      redirect_back_or_default
    end
  end

  def redirect_back
    redirect_to(request.referer)
  end

end

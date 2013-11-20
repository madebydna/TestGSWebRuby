module SessionConcerns
  extend ActiveSupport::Concern

  STORED_LOCATION_EXPIRATION = 15.minutes

  def store_location(uri = nil, overwrite = true)
    if overwrite
      value = uri || request.original_url
    else
      value = cookies[:return_to] || uri || request.original_url
    end

    cookie = {
      value: value,
      expires: STORED_LOCATION_EXPIRATION.from_now
    }

    cookies[:return_to] = cookie
  end

  def stored_location
    stored_location = cookies[:return_to]
    if stored_location.present? && stored_location.include?('://')
      stored_location
    end
  end

  # Redirect to the URI stored by the most recent store_location call or to the passed default.
  def redirect_back_or_default(default = request.referer || request.original_url) # TODO: change default
    stored_location = cookies[:return_to]
    if stored_location.present? && stored_location.include?('://')
      redirect_to stored_location
    else
      redirect_to default
    end
    cookies.delete :return_to
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

end

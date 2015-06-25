class ReviewsController < ApplicationController
  include AuthenticationConcerns
  include DeferredActionConcerns
  include ReviewControllerConcerns

  def flag
    review_id = params[:id]
    comment = params.fetch(:review_flag, {})[:comment]

    if review_id.blank? || comment.blank?
      flash_error t('actions.generic_error')
      redirect_back
      return
    end

    if logged_in? && ! current_user.provisional?
      flag_review_and_redirect review_id: review_id, comment: comment
    else
      save_deferred_action :report_review_deferred, review_id: review_id, comment: comment
      if ! logged_in?
      flash_error t('actions.report_review.login_required')
        redirect_to signin_url
        return
      end
      if current_user.provisional?
        verification_email_url = url_for(:controller => 'user', :action => 'send_verification_email', :email => current_user.email)
        flash_error t('actions.report_review.email_verification_required', verification_email_url: verification_email_url).html_safe
        redirect_back
        return
      end
    end
  end

end

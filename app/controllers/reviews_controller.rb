class ReviewsController < ApplicationController
  include AuthenticationConcerns
  include DeferredActionConcerns
  include ReviewControllerConcerns

  def flag
    review_id = params[:id]
    comment = params.fetch(:review_flag, {})[:comment]
    require 'pry'; binding.pry

    if review_id.blank? || comment.blank?
      flash_error t('actions.generic_error')
      redirect_back
      return
    end

    if logged_in?
      report_review_and_redirect reported_id: review_id, comment: comment
    else
      save_deferred_action :report_review_deferred, review_id: review_id, comment: comment
      flash_error t('actions.report_review.login_required')
      redirect_to signin_url
    end
  end

end

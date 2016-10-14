class ReviewsController < ApplicationController
  include AuthenticationConcerns
  include DeferredActionConcerns
  include ReviewControllerConcerns

  skip_before_filter :verify_authenticity_token, if: proc { |c| c.request.xhr? }

  def create
    if logged_in?
      @reviews_form = ReviewsForm.new(
        reviews_form_params.merge({user: current_user})
      )
      if @reviews_form.save
        response_hash = @reviews_form.hash_result
        status = :ok
      else
        response_hash = @reviews_form.errors.to_json
        status = :unprocessable_entity
      end
    else
      status = :unprocessable_entity
      response_hash = {redirect_url: join_url}
    end
    respond_to do |format|
      format.json { render json: response_hash, status: status}
    end
  end

  def flag
    review_id = params[:id]
    comment = params.fetch(:review_flag, {})[:comment]

    if review_id.blank? || comment.blank?
      flash_error t('actions.generic_error')
      if request.xhr?
        render json: {}, status: :unprocessable_entity
      else
        redirect_back
      end
      return
    end

    if logged_in? && ! current_user.provisional?
      flag_review_and_redirect review_id: review_id, comment: comment
    else
      save_deferred_action :report_review_deferred, review_id: review_id, comment: comment
      if ! logged_in?
        flash_error t('actions.report_review.login_required')
        if request.xhr?
          render json: {}, status: :forbidden
        else
          redirect_to signin_url
        end
        return
      end
      if current_user.provisional?
        verification_email_url = url_for(:controller => 'user', :action => 'send_verification_email', :email => current_user.email)
        flash_notice t('actions.report_review.email_verification_required')
        if request.xhr?
          render json: {}, status: :forbidden
        else
          redirect_back
        end
        return
      end
    end
  end

  private

  def reviews_form_params
      params.permit(:school_id, :state, :reviews_params)
  end
end

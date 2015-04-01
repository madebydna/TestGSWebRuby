class ReviewsController < SchoolProfileController
  include AuthenticationConcerns
  include ReviewHelper
  include ReviewControllerConcerns

  def new
    @review = Review.new
  end

  def create
    json_message = {}
    status = :ok
    review_params = params[:review]

    if logged_in?
      review, errors = build_review_params(review_params).save_new_review
      if errors
        status = :unprocessable_entity
        json_message = errors
      else
        status = :created
      end
    else
      save_deferred_action :save_review_deferred, review_params
      json_message[:redirect_url] = gsr_login_url
      status = :ok
    end

    respond_to do |format|
      format.json { render json: json_message, status: status }
    end
  end

  def store_review_in_session
    true
  end

  def report
    review_id = params[:reported_entity_id]
    reason = params.fetch(:reported_entity, {})[:reason]

    if review_id.blank? || reason.blank?
      flash_error t('actions.generic_error')
      redirect_back
      return
    end

    if logged_in?
      report_review_and_redirect reported_entity_id: review_id, reason: reason
    else
      save_deferred_action :report_review_deferred, reported_entity_id: review_id, reason: reason
      flash_error t('actions.report_review.login_required')
      redirect_to signin_url
    end
  end

private

  def review_params
    params.require(:review).permit(:school_id, :state, :review_question_id, :comment,
    review_answers_attributes:[ :value, :review_id])
  end

end

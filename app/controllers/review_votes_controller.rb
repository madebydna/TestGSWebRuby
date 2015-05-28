class ReviewVotesController < ApplicationController
  include DeferredActionConcerns
  include ReviewVotingConcerns

  before_action :require_review, only: [:create, :destroy]
  before_action :require_login_or_defer_action, only: [:create, :destroy]

  def create
    json_message = {}
    status = :ok

    review_vote, errors = build_review_voting_object(params).vote_for_review
    if errors
      json_message['error'] = errors.first
      status = :unprocessable_entity
    else
      json_message = ReviewVote.vote_count_by_id(review_from_param.id)
    end

    respond_to do |format|
      format.json { render json: json_message, status: status }
    end
  end

  def destroy
    json_message = {}
    status = :ok

    review_vote, errors = build_review_voting_object(params).unvote_review
    if errors
      json_message['error'] = errors.first
      status = :unprocessable_entity
    else
      json_message = ReviewVote.vote_count_by_id(review_from_param.id)
    end

    respond_to do |format|
      format.json { render json: json_message, status: status }
    end
  end

  protected

  def require_review
    unless review_from_param.present?
      status = :bad_request
      json_message = {
        error: 'Specified review could not be found'
      }
      respond_to do |format|
        format.json { render json: json_message, status: status }
      end
    end
  end

  def require_login_or_defer_action
    unless logged_in?
      deferred_action = determine_deferred_action
      if deferred_action
        save_deferred_action determine_deferred_action, params
      end
      status = :ok
      json_message = {
        redirect_url: join_url
      }
      respond_to do |format|
        format.json { render json: json_message, status: status }
      end
    end
  end

  def review_from_param
    @review_from_param ||= (
      review_id = params[:id]
      Review.active.find_by(id: review_id)
    )
  end

  def determine_deferred_action
    case action_name
    when 'create'
      :vote_for_review_deferred
    else
    end
  end
end
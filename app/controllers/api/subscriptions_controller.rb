# frozen_string_literal: true

class Api::SubscriptionsController < ApplicationController
  protect_from_forgery

  before_action :login_required

  def create
    unless Subscription.is_invalid?(list) || @current_user.has_signedup?(list, school)
      @current_user.add_subscription!(list, school, language)
      subscription_id = @current_user.subscription_id(list)
    end
    render json: {'id' => subscription_id}
  end

  def login_required
    unless logged_in?
      render json: { errors: ['Not logged in'] }, status: :forbidden
      return false
    end
  end

  def destroy
    subscription = Subscription.find(params[:id]) if params[:id]

    if subscription && @current_user.subscriptions.any? {|s| s.id == subscription.id}
      success = !!subscription.destroy
      success &&= SubscriptionHistory.from_subscription(subscription).save

      if success
        render status: :ok, json: { errors: [] }
      else
        render status: :unprocessable_entity, json: { errors: ['A problem occurred when unsubscribing. Please try again later.']}
      end
    else
      render status: :unprocessable_entity, json: { errors: ['You are not subscribed to the newsletter.']}
    end
  end

  private

  def list
    params[:list]
  end

  def school_id
    params[:schoolId]
  end

  def state
    params[:state]
  end

  def language
    params[:language]
  end

  def school
    return nil unless state && school_id
    @_school ||= School.on_db(state.downcase).find_by(id: school_id)
  end
end
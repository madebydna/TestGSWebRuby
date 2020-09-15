class Admin::Api::SubscriptionsController < ApplicationController

  def index
    @subscriptions = Api::Subscription.includes(:user)
  end

  def pending_approval
    @subscriptions = Api::Subscription.pending_approval.includes(:user)
  end

  def show
    @subscription = Api::Subscription.where(params[:id]).first
  end

  def edit
    @subscription = Api::Subscription.where(params[:id]).first
  end

  def update
    subscription = Api::Subscription.where(params[:id]).first
    subscription.update!(subscription_params)
  end


  def subscription_params
    params.require(:api_subscription).permit(:aws_api_key)
  end


end
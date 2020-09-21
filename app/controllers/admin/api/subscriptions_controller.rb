class Admin::Api::SubscriptionsController < ApplicationController

  def index
    @subscriptions = Api::Subscription.all
  end

  def pending_approval
    @subscriptions = Api::Subscription.pending_approval
  end

  def show
    @subscription = Api::Subscription.find(params[:id])
  end

  def edit
    @subscription = Api::Subscription.find(params[:id])
  end

  def update
    subscription = Api::Subscription.find(params[:id])
    subscription.update!(subscription_params)
  end


  def subscription_params
    params.require(:api_subscription).permit(:aws_api_key)
  end


end
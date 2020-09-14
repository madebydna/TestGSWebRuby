class Admin::Api::SubscriptionsController < ApplicationController
  include Api::ErrorHelper

  layout 'admin'

  def index
    @subscriptions = Api::Subscription.includes(:user)
  end

  def pending_approval
    @subscriptions = Api::Subscription.pending_approval.includes(:user)
  end

  def show
    @subscription = Api::Subscription.where(params[:id]).first
  end

end
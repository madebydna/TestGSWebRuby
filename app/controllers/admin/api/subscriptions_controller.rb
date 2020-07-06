class Admin::Api::SubscriptionsController < ApplicationController
  include Api::ErrorHelper

  layout 'admin'

  def index
    @subscriptions = Api::Subscription.all
  end

  def new
    @user = ::Api::Subscription.new
  end

  def create
    Api::SubscriptionCreator.new(@user, 1).call
  end

  # This occurs when bizdev approves the request
  # def approval(user, price_id)
  #   Api::StripeInteractor.create_subscription(user, price_id)
  # end

end
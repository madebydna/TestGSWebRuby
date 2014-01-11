class SubscriptionsController < ApplicationController
  include PostLoginConcerns
  include SubscriptionConcerns

  def create
    subscription_params = params['subscription']

    if logged_in?
      create_subscription subscription_params
      redirect_back_or_default
    else
      save_post_email_verification_action :create_subscription, subscription_params
      flash_error 'Please log in or register your email in order to get updates on this school.'
      redirect_to signin_path
    end
  end

end
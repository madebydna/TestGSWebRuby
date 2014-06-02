class SubscriptionsController < ApplicationController
  include DeferredActionConcerns
  include SubscriptionConcerns

  def create
    subscription_params = params['subscription']

    if subscription_params[:driver].present?
      set_omniture_evars_in_cookie({'review_updates_mss_traffic_driver' => subscription_params[:driver]})
    end
    set_omniture_events_in_cookie(['review_updates_mss_start_event'])
    set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'SignUpForUpdates'})

    error_message =  'Please log in or register your email in order to follow this school.'
    attempt_sign_up(subscription_params, error_message)

  end

  def subscription_from_link
    if params[:list] == 'gsnewsletter'
      params[:message] = 'You\'ve signed up to receive GreatSchools\'s newsletter'
      error_message = 'Please log in or register your email in order to sign up for GreatSchool\'s newsletter'
      attempt_sign_up(params, error_message, home_path)
    else
      redirect_to home_path
    end
  end

  protected

  def attempt_sign_up(subscription_params, error_message, redirect_path = nil)
    if logged_in?
      create_subscription subscription_params
      redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
    else
      save_deferred_action :create_subscription_deferred, subscription_params
      flash_error error_message
      redirect_to signin_url
    end
  end

end
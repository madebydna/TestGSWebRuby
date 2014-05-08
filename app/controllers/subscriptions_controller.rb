class SubscriptionsController < ApplicationController
  include DeferredActionConcerns
  include SubscriptionConcerns

  def create
    subscription_params = params['subscription']

    #Track the start of "sign up for updates".OM-263
    if subscription_params[:driver].present?
      set_omniture_evars_in_cookie({'review_updates_mss_traffic_driver' => subscription_params[:driver]})
    end
    set_omniture_events_in_cookie(['review_updates_mss_start_event'])
    set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'SignUpForUpdates'})

    if logged_in?
      create_subscription subscription_params
      redirect_back_or_default
    else
      save_deferred_action :create_subscription_deferred, subscription_params
      flash_error 'Please log in or register your email in order to get updates on this school.'
      redirect_to signin_url
    end
  end

end
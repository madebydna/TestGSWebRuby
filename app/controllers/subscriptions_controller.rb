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

    attempt_sign_up(subscription_params, log_in_required_message(subscription_params[:list]))
  end

  def subscription_from_link
    if params[:list] == 'gsnewsletter'
      params[:message] = 'You\'ve signed up to receive GreatSchools\'s newsletter'
      attempt_sign_up(params, log_in_required_message(params[:list]), home_path)
    else
      redirect_to home_path
    end
  end

  def create_subscription_from_account_page
    list = params[:list]
    unless @current_user.has_subscription?(list)
      @current_user.add_subscription!(list)
      result = "User profile failed to update subscription info  for user #{@current_user.email} "

    end
    render json: {'error_msg' => result, 'list' => list}
  end

  def destroy
    success = false
    message = ''

    @subscription = Subscription.find(params[:id]) if params[:id]

    if @subscription && @current_user.subscriptions.any? {|s| s.id == @subscription.id}
      success = !!@subscription.destroy!

      if success
        message = 'You have successfully unsubscribed.'
      else
        message = 'A problem occurred when unsubscribing. Please try again later.'
      end
    else
      message = 'You are not subscribed to the newsletter.'
    end

    @result = {
      success: success,
      message: message
    }
  end

  protected

  def attempt_sign_up(subscription_params, error_message, redirect_path = nil)
    if logged_in?
      puts 'logged in'
      create_subscription subscription_params
      redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
    else
      puts 'NOT logged in'
      save_deferred_action :create_subscription_deferred, subscription_params
      flash_error error_message
      redirect_to join_url
    end
  end

  def log_in_required_message(list = :default)
    list ||= :default
    error_message =  t("actions.subscription.#{list}.login_required")
  end

end

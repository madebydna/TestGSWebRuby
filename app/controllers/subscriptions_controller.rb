class SubscriptionsController < ApplicationController
  include DeferredActionConcerns
  include SubscriptionConcerns

  # the create route is accessed by the sign up button on the footer in all pages
  # and by the sign up for sponsors modal with the modal
  def create
    subscription_params = params['subscription']
    set_omniture_cookies(subscription_params)
    if params.seek(:subscription,:email).present? || logged_in?
      attempt_sign_up(subscription_params)
    elsif
      handle_not_logged_in(subscription_params)
    end
  end

  # Route for adding subscriptions from a direct link for marketers 
  # https://jira.greatschools.org/browse/PT-444
  def subscription_from_link
    if params[:list] == 'gsnewsletter'
      params[:message] = 'You\'ve signed up to receive GreatSchools\'s newsletter'
      if logged_in?
        attempt_sign_up(params, home_path)
      elsif 
        handle_not_logged_in(params)
      end
    else
      redirect_to home_path
    end
  end

  def create_subscription_from_account_page
    list = params[:list]
    unless @current_user.has_signedup?(list)
      @current_user.add_subscription!(list)
      subscription_id = @current_user.subscription_id(list)
      result = "User profile failed to update subscription info  for user #{@current_user.email} "
    end
    render json: {'error_msg' => result, 'list' => list , 'subscription_id' =>subscription_id}
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

  def attempt_sign_up(subscription_params, redirect_path = nil)
    create_subscription subscription_params
    if ajax?
      render json: {}, status: 200
    else
     redirect_path.nil? ? redirect_back_or_default : redirect_back_or_default(redirect_path)
    end
  end

  def handle_not_logged_in(subscription_params)
    error_message = log_in_required_message(subscription_params[:list])
    if ajax?
      render json: {error: error_message}, status: 422
    else
      save_deferred_action :create_subscription_deferred, subscription_params
      flash_error error_message
      redirect_to join_url
    end
  end

  def log_in_required_message(list = :default)
    list ||= :default
    error_message =  t("actions.subscription.#{list}.login_required")
  end

  def set_omniture_cookies(subscription_params)
    if subscription_params[:driver].present?
      set_omniture_evars_in_cookie({'review_updates_mss_traffic_driver' => subscription_params[:driver]})
    end
    set_omniture_events_in_cookie(['review_updates_mss_start_event'])
    set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'SignUpForUpdates'})
  end

  def ajax?
    request.xhr?
  end

end

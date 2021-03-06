class UserEmailUnsubscribesController < ApplicationController

  protect_from_forgery

  before_action only: [:new] do
    token = params[:token]
    login_user_from_token(token)
  end
  before_action :login_required, only: [:new, :create]

  layout 'deprecated_application'

  def new
    @page_name = 'User Email Unsubscribe'
    gon.pagename = @page_name
    set_tracking_info
  end

  def create
    UserSubscriptionManager.new(current_user).unsubscribe
    flash_notice t('controllers.user_email_unsubscribes_controller.success')
    redirect_to user_preferences_path
  end

  private

  def login_user_from_token(token)
    user = UserVerificationToken.user(token)
    log_user_in(user) if user
  end

  def set_tracking_info
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = 'GS:Email:Unsubscribe'
  end
end

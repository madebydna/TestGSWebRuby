class UserEmailUnsubscribesController < ApplicationController

  protect_from_forgery

  before_action only: [:new] do
    token = params[:token]
    login_user_from_token(token)
  end
  before_action :login_required, only: [:new, :create]

  layout 'application'

  def new
    @page_name = 'User Email Unsubscribe'
    gon.pagename = @page_name
  end

  def create
    UserSubscriptionManager.new(current_user).unsubscribe
    flash_notice 'You have unsubscribed from all GreatSchool emails'
    render :new
  end

  private

  def login_user_from_token(token)
    user = UserVerificationToken.user(token)
    log_user_in(user) if user
  end
end

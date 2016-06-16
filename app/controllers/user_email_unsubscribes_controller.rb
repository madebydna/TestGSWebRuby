class UserEmailUnsubscribesController < ApplicationController

  include AccountHelper
  include AuthenticationConcerns

  protect_from_forgery

  before_action only: [:new] do
    token = params[:token]
    verify_and_login_user(token)
  end
  before_action :login_required, only: [:create]

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

end

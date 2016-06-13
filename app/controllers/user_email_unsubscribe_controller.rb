class UserEmailUnsubscribeController < ApplicationController

  include AccountHelper

  protect_from_forgery

  before_action only: [:show] do
    token = params[:token]
    verify_and_login_user(token)
  end

  layout 'application'

  def show
    @page_name = 'User Email Unsubscribe'
    gon.pagename = @page_name
  end

end

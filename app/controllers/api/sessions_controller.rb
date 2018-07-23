class Api::SessionsController < ApplicationController

  def show
    headers['X-Robots-Tag'] = 'noindex, nofollow'
    render json: { errors: ['Not logged in'] }, status: :forbidden unless logged_in? # :forbidden = 403
    @user = current_user
  end
end

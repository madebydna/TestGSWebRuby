class Api::SessionsController < ApplicationController

  def show
    render json: {}, status: :forbidden unless logged_in? # :forbidden = 403
    @user = current_user
  end
end

class UserController < ApplicationController

  def email_available
    email = params[:email]
    result = ! User.exists?(email: email)

    respond_to do |format|
      format.js { render json: result }
    end
  end

end
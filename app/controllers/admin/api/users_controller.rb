class Admin::Api::UsersController < ApplicationController
  OFFSET = 100

  def index
    @users = Api::User.all
  end

  def new
    @user = ::Api::User.new
  end

  def create
    @user = Api::User.new(user_params)
    if @user.save
      # ApiRequestReceivedEmail.deliver_to_api_key_requester(@user)
      # ApiRequestToModerateEmail.deliver_to_admin(@user)
      Api::StripeCustomerCreator.create(user)
      redirect_to :success
    else
      render 'new'
    end
  end

  def success
  end

  def user_params
    params.require(:user).permit(:id,
                                 :first_name,
                                 :last_name,
                                 :organization,
                                 :email,
                                 :website,
                                 :phone,
                                 :city,
                                 :state,
                                 :intended_use,
                                 :type,
                                 :account_updated,
                                 :email_confirmation)
  end

end
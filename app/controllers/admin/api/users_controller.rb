class Admin::Api::UsersController < ApplicationController
  include Api::ErrorHelper

  OFFSET = 100
  layout 'admin'

  def index
    @users = Api::User.all
  end

  def new
    @user = ::Api::User.new
  end

  def billing
    user    = ::Api::User.last
    @intent = Stripe::SetupIntent.create_customer({ customer: user.stripe_customer_id })
  end

  def create
    @user = ::Api::User.new(user_params)
    if @user.save
      # ApiRequestReceivedEmail.deliver_to_api_key_requester(@user)
      # ApiRequestToModerateEmail.deliver_to_admin(@user)
      stripe_customer_id = Api::StripeInteractor.create(@user)
      render :billing
    else
      render :new
    end
  end

  def success
  end

  def user_params
    params.require(:api_user).permit(:id,
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
                                     :email_confirmation,
                                     :organization_description,
                                     :role,
                                     :intended_use_details
    )
  end

end
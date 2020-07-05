class Admin::Api::UsersController < ApplicationController
  include Api::ErrorHelper

  layout 'admin'

  def index
    @users = Api::User.all
  end

  def new
    @user = ::Api::User.new
  end

  def create
    @user = Api::User.new(user_params)
    if @user.save
      Api::SubscriptionCreator.new(@user, 1).call
      stripe_customer_id = Api::StripeCustomerCreator.new(@user).call
      intent             = Api::StripeInteractor.create_intent(stripe_customer_id)
      redirect_to action: 'billing', client_secret: intent.client_secret
    else
      render :new
    end
  end

  def billing
    @client_secret = params[:client_secret]
  end

  def notify_user
    # ApiRequestReceivedEmail.deliver_to_api_key_requester(@user)
  end

  def notify_admin
    # ApiRequestToModerateEmail.deliver_to_admin(@user)
  end

  def confirmation
    notify_user
    notify_admin
  end

  def approval(user, price_id)
    Api::StripeInteractor.create_subscription(user, price_id)
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
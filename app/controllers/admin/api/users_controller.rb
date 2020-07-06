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
      Api::StripeCustomerCreator.new(@user).call
      Api::SubscriptionCreator.new(@user, 1).call
      redirect_to action: 'billing', user_id: @user.id
    else
      render :new
    end
  end

  def billing
    user = Api::User.find(params['user_id'])
    @intent = Api::StripeInteractor.create_intent(user.stripe_customer_id)
  end

  def confirmation
    @subscription = Api::Subscription.find('subscription_id').update(status: 'payment_added')
    notify_user
    notify_admin
  end

  def notify_user
    # ApiRequestReceivedEmail.deliver_to_api_key_requester(@user)
  end

  def notify_admin
    # ApiRequestToModerateEmail.deliver_to_admin(@user)
  end

  def complete
    # SubscriptionUpdaterJob.perform_later(subscription_id: subscription_id, status: 'awaiting_bizdev_approval')
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
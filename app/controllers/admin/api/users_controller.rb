class Admin::Api::UsersController < ApplicationController
  include Api::ErrorHelper
  include Api::ViewHelper

  layout 'admin'

  before_action :require_user, only: [:billing, :update, :confirmation]

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

  def update
    # TODO! Do we need to save anything from the results hash coming back from stripe?
    @results = params['result']
    payment_object ||= Stripe::PaymentMethod.retrieve(@results[:setupIntent][:payment_method])
    
    session[:user_id] = user.id
    session[:billing_details] = payment_object[:billing_details]
    session[:card] = payment_object[:card]

    respond_to do |format|
      format.js
    end
  end

  def billing
    @intent = Api::StripeInteractor.create_intent(user.stripe_customer_id)
  end

  def confirmation
    redirect_to api_registration_path unless session[:billing_details].present? && session[:card].present?

    card_details ||= session[:card]
    billing_details ||= session[:billing_details]

    @card_details = OpenStruct.new({
      last_four: card_details[:last4],
      brand: card_details[:brand],
      name: billing_details[:name],
      address: [billing_details[:address][:line1], billing_details[:address][:line2]].compact.join(' ')&.strip,
      locality: "#{billing_details[:address][:city]&.capitalize}, #{billing_details[:address][:state]&.upcase}",
      zipcode: billing_details[:address][:postal_code]
    })

    # @subscription = Api::Subscription.find('subscription_id').update(status: 'payment_added')
    # notify_user
    # notify_admin
  end

  def receipt
    @user = Api::User.find(29)
    # email biz
    session[:billing_details] = nil
    session[:card] = nil
    session[:user_id] = nil
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

  private

  def user
    @user ||= Api::User.find_by_id(params['user_id'] || session[:user_id])
  end

  def require_user
    redirect_to root_url unless user
  end

end
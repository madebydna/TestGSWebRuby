class Admin::Api::UsersController < ApplicationController
  include Api::ErrorHelper
  include Api::ViewHelper

  layout 'admin'

  before_action :require_user, only: [:billing, :update, :confirmation, :receipt, :plan_update]

  def index
    @users = Api::User.all
  end

  def new
    session[:plan_id] = params[:plan_id]
    @user = ::Api::User.new
  end

  def create
    @user = Api::User.new(user_params)
    if @user.save
      Api::StripeCustomerCreator.new(@user).call
      Api::SubscriptionCreator.new(@user, session[:plan_id]).call
      session[:api_user_id] = @user.id
      redirect_to action: 'billing'
    else
      render :new
    end
  end

  def update
    # TODO! Do we need to save anything from the results hash coming back from stripe?
    @results = params['result']
    payment_object ||= Stripe::PaymentMethod.retrieve(@results[:setupIntent][:payment_method])

    session[:api_user_id] = user.id
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
    redirect_to api_billing_path unless session[:billing_details].present? && session[:card].present?
    @card_details = Api::CreditCardDetails.call(session[:card], session[:billing_details])

    # @subscription = Api::Subscription.find('subscription_id').update(status: 'payment_added')
    # notify_user
    # notify_admin
  end

  def receipt
    # email biz here
    session[:billing_details] = nil
    session[:card] = nil
    session[:api_user_id] = nil
  end

  def plan_update
    subscription = Api::Subscription.find_by(id: params[:subscription_id])
    return unless subscription.present?

    subscription.update(plan_id: params[:plan_id])

    respond_to do |format|
      format.js
    end
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

  def api_user
    @api_user ||= Api::User.find_by_id(session[:api_user_id])
  end

  def require_user
    redirect_to api_signup_path unless api_user
  end

end
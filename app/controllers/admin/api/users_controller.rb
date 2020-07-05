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
    user    = Api::User.new(user_params)
      creator = Api::UserCreator.new(user, params[:plan_id])
    @user   = creator.create
    if @user
      redirect_to action: 'billing', intent: creator.intent
    else
      render :new
    end
  end

  def billing
  end

  def confirmation
    #
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
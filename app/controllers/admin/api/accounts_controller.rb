class Admin::Api::AccountsController < ApplicationController
  layout 'admin'

  def index
    @accounts = Api::Subscription.includes(:user)
  end

  def pending_approval
    @accounts = Api::Subscription.pending_approval.includes(:user)
  end

  def show
    @account = Api::Subscription.find(params[:id])
  end

  def edit
    @account = Api::Subscription.find(params[:id])
  end

  def update
    @subscription = Api::Subscription.find(params[:id])
    @subscription.update!(subscription_params)
    redirect_to edit_admin_api_account_path(@subscription)
  end

  def approve
    AccountApprover.new(params[:id]).approve
    redirect_to edit_admin_api_account_path(@subscription)
  end

  def subscription_params
    params.require(:api_subscription).permit(:aws_api_key)
  end

end
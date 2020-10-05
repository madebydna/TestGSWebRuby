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
    @account = Api::Subscription.find(params[:id])
    @account.update!(account_params)
    redirect_to edit_admin_api_account_path(@account)
  end

  def approve
    @account = Api::AccountApprover.new(params[:id]).process
    redirect_to edit_admin_api_account_path(@account)
  end

  def reject
    @account = Api::AccountRejector.new(params[:id]).process
    redirect_to edit_admin_api_account_path(@account)
  end

  def deactivate
    @account = Api::AccountDeactivator.new(params[:id]).process
    redirect_to edit_admin_api_account_path(@account)
  end

  def account_params
    params.require(:api_subscription).permit(:aws_api_key, :notes, :end_date)
  end

end
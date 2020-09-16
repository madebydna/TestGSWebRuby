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
    # activate subscription in stripe and charge user
    # on success:
    # update our local data store (Api::Subscription table set status to active)
    # send an email to user confirming start of subscription and subscription details
    # on failure:
    # send an email to user confirming failed approval
    # send an email to bizdev

    @subscription = Api::Subscription.find(params[:id])
    @subscription.update(status: 'bizdev_approved')
    result = Api::SubscriptionCreator.new(@subscription.user, 'price_1H0VXAC0DFRCPjlNgnmXLZu6').call
    redirect_to edit_admin_api_account_path(@subscription)
  end

  def subscription_params
    params.require(:api_subscription).permit(:aws_api_key)
  end

end
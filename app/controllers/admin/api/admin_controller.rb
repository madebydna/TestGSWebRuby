class Admin::Api::AdminController < ApplicationController

  layout 'admin'

  def index
    @subscriptions = Api::Subscription.includes(:user)
  end

  def pending_approval
    @subscriptions = Api::Subscription.pending_approval.includes(:user)
  end

end
class AccountManagementController < ApplicationController
  include PageAnalytics
  protect_from_forgery
  before_action :login_required
  layout 'application'

  def show
    set_meta_tags(
      title: "My account | GreatSchools",
      robots: "noindex"
    )
    render 'show'
  end
end
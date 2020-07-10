class AccountManagementController < ApplicationController
  include PageAnalytics
  protect_from_forgery
  before_action :login_required
  layout 'application'

  set_additional_js_translations(
    {
      account: [:lib, :account]
    }
  )

  def show
    set_meta_tags(
      title: "My account | GreatSchools",
      robots: "noindex"
    )
  end

  private

  def set_global_ad_targeting_through_gon
    # override default behavior. dont need to check property table
  end
end
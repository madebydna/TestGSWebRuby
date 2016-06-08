class UserEmailPreferencesController < ApplicationController
  protect_from_forgery

  include AccountHelper

  layout 'application'

  before_action :login_required

  def show
    @page_name = 'User Email Preferences'
    gon.pagename = @page_name

    @subscriptions = UserSubscriptions.new(@current_user).get

    account_meta_tags

    @display_grade_level_array = grade_array_pk_to_8
    @selected_grade_level = @current_user.student_grade_levels
  end

  def account_meta_tags
    set_meta_tags :title => "My email preferences | GreatSchools",
                  :robots => "noindex"
  end

end
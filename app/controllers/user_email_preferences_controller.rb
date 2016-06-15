class UserEmailPreferencesController < ApplicationController

  include AccountHelper

  protect_from_forgery
  before_action only: [:show] do
    token = params[:token]
    verify_and_login_user(token)
  end

  layout 'application'

  def show
    @page_name = 'User Email Preferences'
    gon.pagename = @page_name

    @subscriptions = UserSubscriptions.new(@current_user).get

    account_meta_tags('My email preferences')

    @display_grade_level_array = grade_array_pk_to_8

    @selected_grade_level = @current_user.student_grade_levels.map(&:grade).join(",")
  end

  def update
    UserSubscriptionManager.new(@current_user).update(validate_update_subscriptions)
    UserGradeManager.new(@current_user).update(validate_update_grades)

  end

  def validate_update_grades
    params['grades']
    #['1','2','3','4']
  end

  def validate_update_subscriptions
    params['subscriptions']
      # ['sponsor']
  end
end


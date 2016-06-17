class UserEmailPreferencesController < ApplicationController

  include AccountHelper

  protect_from_forgery
  before_action only: [:show] do
    token = params[:token]
    login_user_from_token(token)
  end
  before_action :login_required, only: [:show, :update]

  layout 'application'

  def show
    @page_name = 'User Email Preferences'
    gon.pagename = @page_name

    @current_preferences = UserSubscriptions.new(@current_user).get

    @current_preferences << :auto_graduate if @current_user.opted_in_auto_graduate?

    account_meta_tags('My email preferences')

    @display_grade_level_array = grade_array_pk_to_8

    @selected_grade_level = @current_user.student_grade_levels.map(&:grade).join(",")

    @available_grades = {
      'PK' => 'PK',
      'K' => 'K',
      '1' => '1st',
      '2' => '2nd',
      '3' => '3rd',
      '4' => '4th',
      '5' => '5th',
      '6' => '6th',
      '7' => '7th',
      '8' => '8th'
    }
  end

  def update
    UserSubscriptionManager.new(@current_user).update(validate_update_subscriptions)
    UserGradeManager.new(@current_user).update(validate_update_grades)
    @current_user.update_auto_graduate(validate_update_auto_graduate)
  end

  def validate_update_grades
    params['grades']
    #['1','2','3','4']
  end

  def validate_update_subscriptions
    params['subscriptions']
      # ['sponsor']
  end

  def validate_update_auto_graduate
    params['auto_graduate']
    # ['sponsor']
  end

  private

  def login_user_from_token(token)
    user = UserVerificationToken.user(token)
    log_user_in(user) if user
  end
end


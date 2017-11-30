class UserEmailPreferencesController < ApplicationController

  include AccountHelper

  protect_from_forgery
  before_action only: [:show] do
    token = params[:token]
    login_user_from_token(token)
  end
  before_action :login_required, only: [:show, :update]

  layout 'deprecated_application'

  def show
    @page_name = 'User Email Preferences' # This is also hardcoded in email_preferences.js
    gon.pagename = @page_name
    @current_preferences = UserSubscriptions.new(@current_user).get
    account_meta_tags('My email preferences')
    @current_grades = @current_user.student_grade_levels.map(&:grade)
    @available_grades = available_grades
    @mss_subscriptions = current_user
      .subscriptions_matching_lists([:mystat, :mystat_private, :mystat_unverified])
      .extend(SchoolAssociationPreloading).preload_associated_schools!
    set_tracking_info
  end

  def update
    UserSubscriptionManager.new(@current_user).update(param_subscriptions)
    UserGradeManager.new(@current_user).update(param_grades)
    Subscription.where(id: subscription_ids_to_remove, member_id: current_user.id).destroy_all if subscription_ids_to_remove
    flash_notice t('controllers.user_email_preferences_controller.success')
    redirect_to home_path
  end

  def param_grades
    params['grades'] || []
    #['1','2','3','4']
  end

  def param_subscriptions
    params['subscriptions'] || []
  end

  def subscription_ids_to_remove
    params['subscription_ids_to_remove']
  end

  private

  def login_user_from_token(token)
    user = UserVerificationToken.user(token)
    log_user_in(user) if user
  end

  def set_tracking_info
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = 'GS:Email:Preferences'
  end
end


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
    @current_preferences_en = UserSubscriptions.new(@current_user).get.select { |sub| sub[:language] == 'en' }.map(&:list)
    @current_preferences_es = UserSubscriptions.new(@current_user).get.select { |sub| sub[:language] == 'es' }.map(&:list)
    account_meta_tags('My email preferences')
    @current_grades = current_district_grades
    @current_grades_en = current_district_grades.select { |el| el[:language] == 'en' }
    @current_grades_es = current_district_grades.select { |el| el[:language] == 'es' }
    @available_grades = available_grades
    @available_grades_spanish = available_grades_spanish
    @grades_hashes = create_grades
    @mss_subscriptions = current_user
      .subscriptions_matching_lists([:mystat, :mystat_private, :mystat_unverified])
      .extend(SchoolAssociationPreloading).preload_associated_schools!
    @mss_subscriptions_en = current_user
      .subscriptions_matching_lists([:mystat, :mystat_private, :mystat_unverified], "en")
      .extend(SchoolAssociationPreloading).preload_associated_schools!
    @mss_subscriptions_es = current_user
      .subscriptions_matching_lists([:mystat, :mystat_private, :mystat_unverified], "es")
      .extend(SchoolAssociationPreloading).preload_associated_schools!
    set_tracking_info
  end


  def update
    # require 'pry'; binding.pry;
    UserSubscriptionManager.new(@current_user).update(param_subscriptions)
    UserGradeManager.new(@current_user).update(param_grades)
    Subscription.where(id: school_subscription_ids_to_remove_en, member_id: current_user.id).destroy_all if school_subscription_ids_to_remove_en
    Subscription.where(id: school_subscription_ids_to_remove_es, member_id: current_user.id).destroy_all if school_subscription_ids_to_remove_es
    flash_notice t('controllers.user_email_preferences_controller.success')
    redirect_to user_preferences_path
  end

  def param_grades
    params['grades'] || []
    #['1','2','3','4']
  end

  # TODO: Filter by en
  def param_grades_en
    params['grades'] || []
    #['1','2','3','4']
  end

  # TODO: Filter by es
  def param_grades_es
    params['grades_es'] || []
    #['1','2','3','4']
  end

  # TODO: Remove this
  def param_subscriptions
    {
      'en' => param_subscriptions_en,
      'es' => param_subscriptions_es
    }
  end

  def param_subscriptions_en
    params['subscriptions_en'] || []
  end

  def param_subscriptions_es
    params['subscriptions_es'] || []
  end

  # TODO: Remove this
  def school_subscription_ids_to_remove
    params['subscription_ids_to_remove_en']
  end

  def school_subscription_ids_to_remove_en
    params['subscription_ids_to_remove_en']
  end

  def school_subscription_ids_to_remove_es
    params['subscription_ids_to_remove_es']
  end

  def current_district_grades
    records = @current_user.student_grade_levels
    records.map do |record|
      {
        :grade => record.grade,
        :district_state => record.district_state,
        :district_id => record.district_id,
        :language => record.language,
        :district_state_and_id => "#{record.district_state}-#{record.district_id}",
        :district_name => DistrictRecord.find_by(state: record.district_state, district_id: record.district_id)&.name
      }
    end
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


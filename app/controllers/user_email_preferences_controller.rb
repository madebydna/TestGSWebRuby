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
    @page_name = 'User Email Preferences' # This is also hardcoded in email_preferences.js
    gon.pagename = @page_name
    all_user_subscriptions = @current_user.subscriptions
    @subscriptions = subscriptions(all_user_subscriptions)
    @mss_subscriptions = mss_subscriptions(all_user_subscriptions)
    @grades_hashes = create_grades
    account_meta_tags('My email preferences')
    set_tracking_info
  end


  def update
    UserEmailSubscriptionManager.new(@current_user).update(process_subscriptions(param_subscriptions))
    UserEmailSubscriptionManager.new(@current_user).update_mss(process_schools(param_schools))
    UserEmailGradeManager.new(@current_user).update(process_grades(param_grades))
    flash_notice t('controllers.user_email_preferences_controller.success')
    redirect_to user_preferences_path(lang: params["lang"], tab: params["tab"])
  end

  def param_grades
    params['grades'] || []
    #['1','2','3','4']
  end

  def param_subscriptions
    params['subscriptions'] || []
  end

  def param_schools
    params['schools'] || []
  end

  def subscriptions(all_user_subscriptions)
    sub_whitelist = %w(sponsor teacher_list greatnews greatkidsnews)
    subs = all_user_subscriptions.select { |subscription| sub_whitelist.include? subscription[:list] }
    subs.map { |s| {list: s[:list], language: s[:language]} }
  end

  def mss_subscriptions(all_user_subscriptions)
    sub_whitelist = %w(mystat mystat_private mystat_unverified)
    filtered_subs = all_user_subscriptions.select do |subscription|
      sub_whitelist.include? subscription[:list] and
          subscription[:school_id].present? and
          subscription[:state].present?
    end.extend(SchoolAssociationPreloading).preload_associated_schools!
    create_mss_structure(filtered_subs)
  end

  def create_mss_hash(subs, language, school_id, school_state, active)
    s = subs.select { |sub| sub.school_id&.to_s == school_id and sub.school_state == school_state }.first
    {
        list: s[:list],
        language: language,
        school_id: s[:school_id],
        active: active,
        state: s[:state],
        school_name: s.school.name,
        school_city: s.school.city,
        school_state: s.school.state
    }
  end

  def create_mss_structure(subs)
    schools = subs.map { |g| "#{g.state}#{g.school_id}" }.uniq.compact.select { |element| element&.size.to_i > 0 }
    {
        :en => {
            :schools => schools.map { |school| create_school(school, subs, 'en') }
        },
        :es => {
            :schools => schools.map { |school| create_school(school, subs, 'es') }
        }
    }
  end

  def mss_subscription_active?(subs, language, school_id, school_state)
    subs.select do |sub|
      sub[:school_id]&.to_s == school_id and sub[:state] == school_state and sub[:language] == language
    end.present?
  end

  def create_school(school, subs, language)
    school_id = school[2, 6]
    school_state = school[0..1]
    active = mss_subscription_active?(subs, language, school_id, school_state)
    create_mss_hash(subs, language, school_id, school_state, active)
  end


  def create_grades
    grades = @current_user.student_grade_levels
    create_grade_structure(grades)
  end

  def create_grade_structure(grades)
    districts = grades.map { |g| "#{g.district_state}#{g.district_id}" }.uniq.compact.select { |element| element&.size.to_i > 0 }
    {
        :en => {
            :overall => create_overall(grades, 'en'),
            :districts => districts.map { |district| create_district(district, grades, 'en') }
        },
        :es => {
            :overall => create_overall(grades, 'es'),
            :districts => districts.map { |district| create_district(district, grades, 'es') }
        }
    }
  end

  def grades_select(grades, language, district_id = nil, district_state = nil)
    grades.select do |grade|
      grade[:district_id]&.to_s == district_id and grade[:district_state] == district_state and grade[:language] == language
    end.map { |g| g[:grade] }
  end

  def create_overall(grades, language)
    grade_array = grades_select(grades, language)
    title = language == 'es' ? 'Grado por grado' : 'Grade by Grade'
    create_hash(grade_array, language, title)
  end

  def create_district(district, grades, language)
    district_id = district[2, 6]
    district_state = district[0..1]
    district_name = DistrictRecord.find_by(state: district_state, district_id: district_id)&.name
    title = language == 'es' ? "Grado por grado en #{district_name}" : "Grade by Grade at #{district_name}"
    grade_array = grades_select(grades, language, district_id, district_state)
    create_hash(grade_array, language, title, district_id, district_state)
  end

  def create_hash(grades, language, title, district_id = '', district_state = '')
    path_to_yml = "user_email_preferences.email_preferences.#{language}_news."
    grades_labels = language == 'es' ? available_grades_spanish : available_grades
    {
        :active_grades => grades,
        :district_state => district_state,
        :district_id => district_id,
        :language => language,
        :title => title,
        :subtitle => path_to_yml + "greatkidsnews_subtitle",
        :label => path_to_yml + "select_grades",
        :available_grades => grades_labels
    }
  end

  def process_grades(param_grades)
    parsed_grades = JSON.parse(param_grades)
    parsed_grades.map { |r| [r[0].to_s, r[1], r[2], r[3]] }
  end

  def process_subscriptions(param_subscriptions)
    JSON.parse(param_subscriptions)
  end

  def process_schools(param_schools)
    JSON.parse(param_schools)
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


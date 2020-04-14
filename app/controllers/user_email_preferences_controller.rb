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
    # @available_grades = available_grades
    # @available_grades_spanish = available_grades_spanish

    @grades_hashes = create_grades_new
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

  def create_grades_new
    grades = @current_user.student_grade_levels
    create_grade_structure(grades)
  end

  def create_grade_structure(grades)
    districts = grades.map { |g| "#{g.district_state}#{g.district_id}" }.uniq.compact.select { |element| element&.size.to_i > 0 }
    {
        :en => {
            :overall => create_overall_new(grades, 'en'),
            :districts => districts.map { |district| create_district_new(district, grades, 'en') }
        },
        :es => {
            :overall => create_overall_new(grades, 'es'),
            :districts => districts.map { |district| create_district_new(district, grades, 'es') }
        }
    }
  end

  def grades_select(grades, language, district_id = nil, district_state = nil)
    grades.select do |grade|
      grade[:district_id]&.to_s == district_id and grade[:district_state] == district_state and grade[:language] == language
    end.map { |g| g[:grade] }
  end

  def create_overall_new(grades, language)
    grade_array = grades_select(grades, language)
    title = language == 'es' ? 'Grado por grado' : 'Grade by Grade'
    create_hash_new(grade_array, language, title)
  end

  def create_district_new(district, grades, language)
    district_id = district[2, 6]
    district_state = district[0..1]
    district_name = DistrictRecord.find_by(state: district_state, district_id: district_id)&.name
    title = language == 'es' ? "Grado por grado en #{district_name}" : "Grade by Grade at #{district_name}"
    grade_array = grades_select(grades, language, district_id, district_state)
    create_hash_new(grade_array, language, title, district_id, district_state)
  end

  def create_hash_new(grades, language, title, district_id = '', district_state = '')
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

  def update
    # UserSubscriptionManager.new(@current_user).update(param_subscriptions)
    # UserGradeManager.new(@current_user).update(param_grades)
    # require 'pry'; binding.pry;
    UserEmailGradeManager.new(@current_user).update(process_grades(param_grades))

    # Subscription.where(id: school_subscription_ids_to_remove_en, member_id: current_user.id).destroy_all if school_subscription_ids_to_remove_en
    # Subscription.where(id: school_subscription_ids_to_remove_es, member_id: current_user.id).destroy_all if school_subscription_ids_to_remove_es
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

  # def create_grades
  #   grades = @current_user.student_grade_levels
  #   overall_en = grades.select { |record| record[:language] == 'en' && record[:district_id].blank? && record[:district_state].blank? }
  #   overall_es = grades.select { |record| record[:language] == 'es' && record[:district_id].blank? && record[:district_state].blank? }
  #   district_grades_en = grades.select { |record| record[:language] == 'en' && record[:district_id].present? && record[:district_state].present? }
  #   district_grades_es = grades.select { |record| record[:language] == 'es' && record[:district_id].present? && record[:district_state].present? }

  #   districts_en, districts_es = create_districts(district_grades_en, district_grades_es)

  #   a = {
  #     :en => {
  #             :overall => create_hash(overall_en, 'en'),
  #             :districts => districts_en
  #            },
  #     :es => {
  #             :overall => create_hash(overall_es, 'es'),
  #             :districts => districts_es
  #            }
  #   }
  # end

  # def create_districts(district_en, district_es)
  #   district_en_grades = district_en.group_by { |r| [r[:district_state], r[:district_id]] }
  #   district_es_grades = district_es.group_by { |r| [r[:district_state], r[:district_id]] }
  #   districts_en = {}
  #   districts_es = {}

  #   district_en_grades.each do |k, grade_info|
  #     key = k.join("-")
  #     districts_en[key] = create_district(grade_info)

  #     unless districts_es[key]
  #       district_state = k[0]
  #       district_id = k[1]
  #       district_name = DistrictRecord.find_by(state: district_state, district_id: district_id)&.name

  #       districts_es[key] = create_hash([], 'es', district_state, district_id, district_name)
  #     end
  #   end

  #   district_es_grades.each do |k, grade_info|
  #     key = k.join("-")
  #     districts_en[key] = create_district(grade_info)

  #     unless districts_en[key]
  #       district_state = k[0]
  #       district_id = k[1]
  #       district_name = DistrictRecord.find_by(state: district_state, district_id: district_id)&.name

  #       districts_en[key] = create_hash([], 'en', district_state, district_id, district_name)
  #     end
  #   end
  #   [districts_en, districts_es]
  # end

  # def create_district(grade_info)
  #   district_data = grade_info.first
  #   district_name = DistrictRecord.find_by(state: district_data[:district_state], district_id: district_data[:district_id])&.name

  #   create_hash(grade_info, district_data[:language], district_data[:district_state], district_data[:district_id], district_name)
  # end

  # def create_hash(grade_info = [], language = 'en', district_state = '', district_id = '', district_name = '')
  #   if language == 'es' && district_name.present?
  #     title = "Grado por grado en #{district_name}"
  #   elsif language == 'es'
  #     title = "Grado por grado"
  #   elsif language == 'en' && district_name.present?
  #     title = "Grade by Grade at #{district_name}"
  #   else
  #     title = 'Grade by Grade'
  #   end

  #   grades_labels = language == 'es' ? available_grades_spanish : available_grades

  #   {
  #     :active_grades => grade_info.map { |record| record[:grade] },
  #     :district_state => district_state,
  #     :district_id => district_id,
  #     :language => language,
  #     :district_name => district_name,
  #     :title => title,
  #     :subtitle => "greatkidsnews_subtitle",
  #     :label => "select_grades",
  #     :available_grades => grades_labels
  #   }
  # end

  private

  def login_user_from_token(token)
    user = UserVerificationToken.user(token)
    log_user_in(user) if user
  end

  def set_tracking_info
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = 'GS:Email:Preferences'
  end
end


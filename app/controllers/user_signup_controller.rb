class UserSignupController < ApplicationController

  include AccountHelper

  layout 'application'

  def show
    show_all
    @submit_path = submit_path
    @grades_hashes = grades_hashes
  end

  def show_all
    @page_name = 'User Signup'
    gon.pagename = @page_name
    @grades = param_grades.present? ? formatted_grades_array(param_grades) : param_grades
    @original_url = original_url
    account_meta_tags('Sign up for an account')
    set_tracking_info
  end

  def district_signup
    district = DistrictRecord.find_by(state: params[:state], district_id: params[:district_id])
    @submit_path = district_signup_path
    session[:district_id] = params[:district_id]
    session[:district_state] = params[:state]
    show_all
    @grades_hashes = grades_hashes(district.district_id, district.state)
  end

  def show_spanish
    I18n.locale = :es
    show_all
    @grades_hashes = grades_hashes
    render :show
  end

  def thankyou
    account_meta_tags('Thank you')
  end

  def create
    # TODO: Verify that account does not exist and is valid structure, then create account and add subscriptions below
    user = User.find_by(email: param_email)

    if user || param_email.blank? || is_invalid?(param_email)
      set_variables_repopulate_form
      param_language == 'es' ? show_spanish : show_all
      @grades_hashes = grades_hashes
      render :show
    else
      user = register_user(param_email)
      UserEmailSubscriptionManager.new(user).update(process_subscriptions(param_subscriptions))
      if param_grades.present?
        UserEmailGradeManager.new(user).update(process_grades(param_grades))
      end
      render 'thankyou'
    end
  end

  def create_for_district_signup
    user = User.find_by(email: param_email) || register_user(param_email)

    UserEmailSubscriptionManager.new(user).update(process_subscriptions(param_subscriptions))
    if param_grades.present?
      UserEmailGradeManager.new(user).additive_grades(process_grades(param_grades))
    end
    user.update(how: "#{session[:district_state]}-#{session[:district_id]}-signup")

    render 'thankyou'
  end

  def register_user(email)
    user = User.new
    user.email = email
    user.password = Password.generate_password
    unless user.save!
      GSLogger.error(:signup, nil, message: 'New user failed to save', vars: {
          email: email
      })
    end
    user
  end

  def set_variables_repopulate_form
    subs = JSON.parse(param_subscriptions).flatten
    @teacher_list = subs.include?('teacher_list')
    @greatnews = subs.include?('greatnews')
    @greatkidsnews = subs.include?('greatkidsnews')
    @sponsor = subs.include?('sponsor')
    @email = params['email']
  end

  def formatted_grades_array(pg)
    JSON.parse(pg).flatten.select { |g| grade_array_pk_to_12.include?(g.to_s) }.map(&:to_s)
  end

  def submit_path
    I18n.locale == :es ? user_signup_submit_spanish_path : user_signup_submit_path
  end

  def param_email
    params['email'] || ''
  end

  def param_grades
    params['grades'] || []
    #['1','2','3','4']
  end

  def param_language
    params['language'] || 'en'
    #['1','2','3','4']
  end

  def param_subscriptions
    params['subscriptions'] || []
  end

  def grades_hashes(district_id = nil, district_state = nil)
    {
      :en => {
        :overall => create_overall_grades(language: 'en', district_id: district_id, district_state: district_state)
      },
      :es => {
        :overall => create_overall_grades(language: 'es', district_id: district_id, district_state: district_state)
      }
    }
  end

  def create_overall_grades(language:, district_id:, district_state:)
    title = language == 'es' ? 'Grado por grado' : 'Grade by Grade'
    grades_labels = language == 'es' ? available_grades_spanish : available_grades
    path_to_yml = 'lib.user_signup.'
    {
      :active_grades => @grades,
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

  def is_invalid?(email)
    (email =~ URI::MailTo::EMAIL_REGEXP) != 0
  end

  private

  def set_tracking_info
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = 'GS:Email:Signup'
  end
end


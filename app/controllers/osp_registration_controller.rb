class OspRegistrationController < ApplicationController

  include Latin1CharactersConcerns

  BLACKLISTED_TOP_LEVEL_DOMAINS = ['pl', 'ru']

  before_action :set_city_state
  before_action :set_login_redirect
  before_action :use_gs_bootstrap
  before_action :validate_params, only: [:submit]

  def new

    set_gon_and_metadata!
    @school = school

    if @school.blank?
      render_no_school_template
    elsif is_delaware_public_or_charter_user?
      render 'osp/registration/delaware'
    elsif @current_user.present? && @current_user.is_active_esp_member?
      redirect_to osp_dashboard_path
    else
      render 'osp/registration/new'
    end
  rescue => error
    GSLogger.error(:osp, error, vars: params, message: 'OSP New Page failed')
  end

  def submit
    return render_no_school_template unless (@school = school).present?
    if current_user.present?
      upgrade_user_to_osp_user
    else
      save_new_osp_user
    end
  rescue => error
    flash_notice t('controllers.osp_registration_controller.invalid_esp_params')
    GSLogger.error(:osp, error, vars: params.except(:password, :password_verify), message: 'OSP Submission flow failed')
    render_no_school_template
  end

  private

  def school
    return @_school if defined? @_school
    @_school = if @state.present? && params[:schoolId].present?
                 School.find_by_state_and_id(@state[:short], params[:schoolId])
               end
  end

  def set_gon_and_metadata!
    page_title = 'School Account - Register | GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = 'GS:OSP:Register'
    set_meta_tags title: page_title,
                  description:' Register for a school account to edit your school\'s profile on GreatSchools.',
                  keywords:'School accounts, register, registration, edit profile'
  end

  def is_delaware_public_or_charter_user?
    @state[:short] == 'de' && (school.type == 'public' || school.type == 'charter')
  end

  def save_new_osp_user
    return render 'osp/registration/new' if User.where(email: params[:email]).present?

    user = User.new(user_attrs.merge({email: params[:email], password: params[:password]}))
    begin
      user.save!
    rescue => error
      flash_notice t('controllers.osp_registration_controller.invalid_esp_params')
      GSLogger.error(:osp, error, vars: params.except(:password, :password_verify), message: 'Failed to save new user in esp registration controller')
      return render 'osp/registration/new'
    end

    return render 'osp/registration/new' unless save_esp_membership!(user)

    sign_up_user_for_subscriptions!(user, school, params[:subscriptions])

    OSPEmailVerificationEmail.deliver_to_osp_user(user,osp_email_verification_url(user),school)
    redirect_to(osp_confirmation_path(:state =>params[:state], :schoolId => params[:schoolId]))
  end

  def upgrade_user_to_osp_user
    user = User.where(email: current_user.email).first_or_initialize

    begin
      user.update_attributes(user_attrs)
    rescue => error
      flash_notice t('controllers.osp_registration_controller.invalid_esp_params')
      GSLogger.error(:osp, error, vars: params.except(:password, :password_verify), message: 'Failed to save new user in esp registration controller')
      return render 'osp/registration/new'
    end

    return render 'osp/registration/new' unless save_esp_membership!(user)

    if user.present?
      #Redirect to osp form
      sign_up_user_for_subscriptions!(user, school, params[:subscriptions])
      redirect_to(osp_page_path(:state =>params[:state], :schoolId => params[:schoolId], :page => 1))
    end
  end

  def save_esp_membership!(user)
    esp_membership = EspMembership.where(member_id:user.id).first_or_initialize
    esp_membership.update_attributes(esp_membership_attrs)
    true
  rescue => error
    flash_notice t('controllers.osp_registration_controller.invalid_esp_params')
    GSLogger.error(:osp, error, vars: params.except(:password, :password_verify), message: 'Failed to save esp membership in esp registration controller')
    false
  end

  def validate_params
    unless valid_params?
      GSLogger.warn(:osp, nil, vars: params.except(:password, :password_verify), message: 'Invalid params for OSP Registration')
      if school.present?
        @school = school
        flash_notice t('controllers.osp_registration_controller.invalid_esp_params')
        return render 'osp/registration/new'
      else
        return render_no_school_template
      end
    end
  end

  def valid_params?
    school.present? &&
    valid_password_length &&
    valid_school_website? &&
    not_blacklisted_top_level_domain?(params[:email]) &&
    only_latin1_characters?(params.values_at(:email, :school_website, :first_name, :last_name))
  end

  def valid_school_website?
    website = params[:school_website]
    return true unless website.present?
    website.length <= 100 && not_blacklisted_top_level_domain?(website)
  end

  def valid_password_length
    password = params[:password]
    return true unless password.present?
    password.length >= 6 && password.length <= 14
  end

  def not_blacklisted_top_level_domain?(url)
    begin
      schemeless_url = url.sub('http://', '').sub('https://', '')
      top_level_domain = URI.parse("http://#{schemeless_url}").host.rpartition('.').last
      !BLACKLISTED_TOP_LEVEL_DOMAINS.include?(top_level_domain)
    rescue
      true
    end
  end

  def user_attrs
    {
      first_name: params[:first_name],
      last_name: params[:last_name],
      welcome_message_status: 'never_send',
      how: 'esp'
    }
  end

  def esp_membership_attrs
    @esp_membership_attrs ||= (
      {
        state: @state[:short].upcase,
        school_id: school.id,
        status: 'provisional',
        active: false,
        web_url: params[:school_website],
        job_title: params[:job_title],
        created: Time.now,
        updated: Time.now
      }
    )
  end

  def render_no_school_template
    gon.pagename = "GS:OSP:NoSchoolSelected"
    render 'osp/registration/no_school_selected'
  end

  def osp_email_verification_url(user)
    tracking_code = 'eml_ospverify'
    verification_link_params = {}
    hash, date = EmailVerificationToken.token_and_date(user)
    verification_link_params.merge!(
        id: hash,
        date: date,
        redirect: '/official-school-profile/dashboard/',
        s_cid: tracking_code
    )
    verify_email_url(verification_link_params)
  end

  def sign_up_user_for_subscriptions!(user, school, subscriptions)
    subscriptions ||= []
    if subscriptions.include?('mystat_osp')
      user.safely_add_subscription!('mystat', school)
      user.safely_add_subscription!('osp', school)
    end
    if subscriptions.include?('osp_partner_promos')
      user.safely_add_subscription!('osp_partner_promos', school)
    end
  end
end

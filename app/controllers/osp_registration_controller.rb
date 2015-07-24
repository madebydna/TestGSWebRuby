class OspRegistrationController < ApplicationController

  before_action :set_city_state
  before_action :set_login_redirect
  before_action :use_gs_bootstrap

  def new

    set_gon_and_metadata!

    @school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?

    if @school.blank?
      render 'osp/registration/no_school_selected'
    elsif is_delaware_public_or_charter_user?
      render 'osp/registration/delaware'
    elsif @current_user.present? && @current_user.is_active_esp_member?
      redirect_to osp_dashboard_path
    else
      render 'osp/registration/new'
    end
  end

  def submit
    @school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?
    if current_user.present?
      upgrade_user_to_osp_user(@school)
    else
      save_new_osp_user(@school)
    end
  end

  private

  def set_gon_and_metadata!
    page_title = 'School Account - Register | GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = 'GS:OSP:Register'
    set_omniture_data('GS:OSP:Register', 'Home,OSP,RegisterPage')
    set_meta_tags title: page_title,
                  description:' Register for a school account to edit your school\'s profile on GreatSchools.',
                  keywords:'School accounts, register, registration, edit profile'
  end

  def is_delaware_public_or_charter_user?
    @state[:short] == 'de' && (@school.type == 'public' || @school.type == 'charter')
  end

  def save_new_osp_user(school)
    user = User.new(user_attrs.merge({email: params[:email], password: params[:password]}))
    begin
      user.save!
    rescue => error
      GSLogger.error(:osp, error, vars: params, message: 'Failed to save new user in esp registration controller')
      return render 'osp/registration/new'
    end

    return render 'osp/registration/new' unless save_esp_membership!(user)

    sign_up_user_for_subscriptions!(user, school, params[:subscriptions])

    OSPEmailVerificationEmail.deliver_to_osp_user(user,osp_email_verification_url(user),school)
    redirect_to(osp_confirmation_path(:state =>params[:state], :schoolId => params[:schoolId]))
  end

  def upgrade_user_to_osp_user(school)
    user = User.where(email: current_user.email).first_or_initialize

    begin
      user.update_attributes(user_attrs)
    rescue => error
      GSLogger.error(:osp, error, vars: params, message: 'Failed to save new user in esp registration controller')
      return render 'osp/registration/new'
    end

    return render 'osp/registration/new' unless save_esp_membership!(user)

    if user.present? && school.present?
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
    GSLogger.error(:osp, error, vars: params, message: 'Failed to save esp membership in esp registration controller')
    false
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
    {
      state: @state[:short].upcase,
      school_id: @school.id,
      status: 'provisional',
      active: false,
      web_url: params[:school_website],
      job_title: params[:job_title],
      created: Time.now,
      updated: Time.now
    }
  end

  def osp_email_verification_url(user)
    tracking_code = 'eml_ospverify'
    verification_link_params = {}
    hash, date = user.email_verification_token
    verification_link_params.merge!(
        id: hash,
        date: date,
        redirect: '/official-school-profile/dashboard/',
        s_cid: tracking_code
    )
    path = verify_email_url(verification_link_params)
  end

  def sign_up_user_for_subscriptions!(user, school, subscriptions)
    subscriptions ||= []
    if subscriptions.include?('mystat_osp')
      user.add_subscription!('mystat', school)
      user.add_subscription!('osp', school)
    end
    if subscriptions.include?('osp_partner_promos')
      user.add_subscription!('osp_partner_promos', school)
    end
  end
end

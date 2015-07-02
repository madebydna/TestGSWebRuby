class OspRegistrationController < ApplicationController

  before_action :set_city_state
  before_action :set_login_redirect
  before_action :use_gs_bootstrap

  def new

    page_title = 'School Account - Register | GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = 'GS:OSP:Register'
    set_omniture_data('GS:OSP:Register', 'Home,OSP,RegisterPage')
    set_meta_tags title: page_title,
                  description:' Register for a school account to edit your school\'s profile on GreatSchools.',
                  keywords:'School accounts, register, registration, edit profile'

    @school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?

    if @school.blank?
      render 'osp/registration/no_school_selected'
    elsif is_delaware_public_or_charter_user?
      render 'osp/registration/delaware'
    elsif @current_user.present? && (@current_user.provisional_or_approved_osp_user? || @current_user.is_esp_superuser? || @current_user.is_esp_demigod?)
      redirect_to osp_dashboard_path
    else @state.present? && params[:schoolId].present?
      render 'osp/registration/new'
    end
  end

  def submit
    school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?

    if current_user.present?
      upgrade_user_to_osp_user(school)
    else
      save_new_osp_user(school)
    end

  end

  private

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

  def is_delaware_public_or_charter_user?
    @state[:short] == 'de' && (@school.type == 'public' || @school.type == 'charter')
  end

  def save_new_osp_user(school)
    user_email = params[:email]
    password   = params[:password]
    password_verify = params[:password_verify]
    first_name = params[:first_name]
    last_name = params[:last_name]
    school_website = params[:school_website]
    job_title = params[:job_title]

    user = User.where(email:user_email, password: nil).first_or_initialize
    user.password = password
    user.first_name = first_name
    user.last_name = last_name
    user.welcome_message_status='never_send'
    user.how='esp'

    # create row in user

    begin
      user.save!
    rescue
      return user, user.errors.messages.first[1].first
    end
    #create row in Esp membership

    begin
      esp_membership = EspMembership.where(member_id:user.id).first_or_initialize
      esp_membership.state = @state[:short]
      esp_membership.school_id = school.id
      esp_membership.status = 'provisional'
      esp_membership.active = false
      esp_membership.web_url = school_website
      esp_membership.job_title = job_title
      esp_membership.created = Time.now
      esp_membership.updated = Time.now
      esp_membership.save!

    rescue
      return esp_membership, esp_membership.errors.messages.first[1].first
    end

    sign_up_user_for_subscriptions!(user, school, params[:subscriptions])

    OSPEmailVerificationEmail.deliver_to_osp_user(user,osp_email_verification_url(user),school)
    redirect_to(:action => 'show',:controller => 'osp_confirmation', :state =>params[:state], :schoolId => params[:schoolId])
  end

  def upgrade_user_to_osp_user(school)
    user_email = params[:email]
    first_name = params[:first_name]
    last_name = params[:last_name]
    school_website = params[:school_website]
    job_title = params[:job_title]

    user = User.where(email:user_email).first_or_initialize
    user.first_name = first_name
    user.last_name = last_name
    user.welcome_message_status='never_send'
    user.how='esp'

    # update row in users

    begin
      user.update_attributes(first_name: first_name ,last_name: last_name, school_website: school_website, job_title: job_title)
    rescue
      return user, user.errors.messages.first[1].first
    end

    #create row in Esp membership

    begin
      esp_membership = EspMembership.where(member_id:user.id).first_or_initialize
      esp_membership.state = @state[:short]
      esp_membership.school_id = school.id
      esp_membership.status = 'provisional'
      esp_membership.active = false
      esp_membership.web_url = school_website
      esp_membership.job_title = job_title
      esp_membership.created = Time.now
      esp_membership.updated = Time.now
      esp_membership.save!

    rescue
      return esp_membership, esp_membership.errors.messages.first[1].first
    end

    if user.present? && school.present?
      #Redirect to thank you page
      redirect_to(:action => 'show',:controller => 'osp_confirmation', :state =>params[:state], :schoolId => params[:schoolId])
    end
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

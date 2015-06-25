class OspRegistrationController < ApplicationController
  before_action :set_city_state

  def show

    page_title = 'School Account - Register | GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = 'GS:OSP:Register'
    set_omniture_data('GS:OSP:Register', 'Home,OSP,RegisterPage')
    set_meta_tags title: page_title,
                  description:' Register for a school account to edit your school\'s profile on GreatSchools.',
                  keywords:'School accounts, register, registration, edit profile'

    @school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?
    @parsley_defaults = "data-parsley-trigger=keyup data-parsley-blockhtmltags data-parsley-validation-threshold=0 "

    if @school.blank?
      render 'osp/osp_no_school_selected'
    elsif @state[:short] == 'de' && (@school.type == 'public' || @school.type == 'charter')
      render 'osp/osp_registration_de'
    else @state.present? && params[:schoolId].present?
      render 'osp/osp_register'
    end
  end


  def submit
    school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?
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

    # escape html


    # adding a static email for now to check email sending should send email from user once the saving user part is done
    if user.present? && school.present?
      #Send OSP Verification Email
      OSPEmailVerificationEmail.deliver_to_osp_user(user,osp_email_verification_url(user),school)
      #Redirect to thank you page
      redirect_to(:action => 'show',:controller => 'osp_confirmation', :state =>params[:state], :schoolId => params[:schoolId])
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
end
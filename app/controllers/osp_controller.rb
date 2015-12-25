class OspController < ApplicationController
  include PhotoUploadConcerns
  include PopularCitiesConcerns

  #order of some of these callbacks matter
  before_action :set_login_redirect
  before_action :set_city_state
  before_action :login_required_for_osp, except: [:approve_provisional_osp_user_data]
  before_action :set_osp_school_instance_vars, except: [:approve_provisional_osp_user_data]
  before_action :validate_delaware_users, except: [:approve_provisional_osp_user_data]
  before_action :set_esp_membership_instance_vars, except: [:approve_provisional_osp_user_data]
  after_action :success_or_error_flash, only: [:submit]

  GON_PAGE_NAME = {'1' => 'GS:OSP:BasicInformation', '2' => 'GS:OSP:Academics', '3' => 'GS:OSP:Extracurriculars', '4' => 'GS:OSP:StaffFacilities'}
  PAGE_TITLE = {'1' => 'Basic Information', '2' => 'Academics', '3' => 'Extracurricular & Culture', '4' => 'Facilities & Staff'}
  DB_PAGE_NAME = {'1' => 'basic_information', '2' => 'academics', '3' => 'extracurricular_culture', '4' => 'facilities_staff'}
  RESPONSE_VALIDATIONS = ['school_phone', 'school_fax', 'start_time', 'end_time'] #eventually move into shared module that the queue daemon also uses to validate data
  AUTH_COOKIE_NAME = 'gs_localAuth'
  AUTH_SALT = '9e209040c863f84a31e719795b2577523954739fe5ed3b58a75cff2127075ed1'

  def show
    @osp_data = OspData.new(@school) #add rescue here that shows nice error
    @cities = popular_cities
    render_osp_page
  end

  def submit
    #If performance becomes an issue, look into making this a bulk single insert.
    submit_time = Time.now

    #approve provisional photos. Make this smarter and not have to use a query
    q = OspDisplayConfig.joins(:osp_question).where('osp_questions.question_type' => 'photo_upload').first
    approve_all_images_for_school(@school) if @is_approved_user && DB_PAGE_NAME[params[:page]] == q.try(:page_name)

    questions_and_answers.each do |(question_id, response_key, values)|
      save_response!(question_id, response_key, values, submit_time, @esp_membership_id, @is_approved_user)
    end
    redirect_to(:action => 'show', :state => params[:state], :schoolId => params[:schoolId], :page => params[:redirectPage])
  end

  #ToDo when Java is no longer the proxy, this should not be a route
  def approve_provisional_osp_user_data
    osp_form_responses = OspFormResponse.where(esp_membership_id: params[:membership_id])
    osp_form_responses.each do |osp_form_response|
      create_update_queue_row!(osp_form_response.response)
    end
    approve_all_images_for_member(params[:membership_id])
    # only java is receiving this html, does not matter that it renders blank page
    render text: ''
  end

  def add_image
    number_of_images_for_school = SchoolMedia.where(school_id: @school.id, state: @school.state).all_except_inactive.count
    return render_error_js unless number_of_images_for_school < MAX_NUMBER_OF_IMAGES_FOR_SCHOOL

    begin
      file = params['imageFile']['0']

      return render_error_js unless valid_file?(file)
      school_media = create_image!(file)

      #We are approving all photos for the school if an approved user adds a photo
      #If they add a photo that means they have 'seen' the other photos and has signed off on them
      approve_all_images_for_school(@school) if @is_approved_user
      render_success_js(school_media.id)
    rescue => error
      GSLogger.error(:osp, error, vars: params, message: 'Failed to add image')
      render_error_js
    end
  end

  #test that unauthorized user can't delete images via directly hitting this action and changing params
  def delete_image
    media = SchoolMedia.find(params[:fileId]) rescue (return render_error_js)
    if can_delete_image?(media)
      media.update_attributes(status: SchoolMedia::DISABLED, date_updated: Time.now) and render_success_js(media.id)
    else
      Rails.logger.error("Was not able to delete osp image. time:#{Time.now} params:#{params}")
      render_error_js
    end
  end

  protected

  def questions_and_answers
    params.except(:controller, :action, :page, :redirectPage, :schoolId, :state, :utf8, :authenticy_token, :isFruitcakeSchool, :showOspGateway, :anyPageStarted).map do |param, values|
      begin
        question_id, response_key = param.split('-', 2)
      rescue => error
        GSLogger.warn(:osp, error, vars: params, message: "invalid param #{param}") and next
      end
      next if question_id.to_i == 0
      next unless values.present?

      validate_questions_and_answers(question_id.to_i, response_key, values)
    end.compact
  end

  def validate_questions_and_answers(question_id, response_key, response_values)
    #TODO add validation here to only allow questions/answers that a school is registered for
    #Validate based on question type and for open text use same validation logic as JS
    #eventually move into shared module that the queue daemon also uses to validate data

    if RESPONSE_VALIDATIONS.include?(response_key)
      send("#{response_key}_validation".to_sym, question_id, response_key, response_values)
    else
      [question_id, response_key, [*response_values].uniq]
    end
  end

  def school_phone_validation(question_id, response_key, response_values)
    value = [*response_values].first.to_s
    pn = value.gsub(/[^\d]/, '')
    return nil unless pn.length == 10

    phone_number = "(#{pn[0..2]}) #{pn[3..5]}-#{pn[6..9]}" #ex (345) 123-5678

    [question_id, response_key, [phone_number]]
  end

  alias school_fax_validation :school_phone_validation

  def start_time_validation(question_id, response_key, response_values)
    time = [*response_values].first.to_s
    return nil unless time =~ /^(0[0-9]|1[0-2]):[0-5](0|5)\s(AM|PM)$/

    [question_id, response_key, [time]]
  end

  alias end_time_validation :start_time_validation

  def save_response!(question_id, question_key, response_values, submit_time, esp_membership_id, is_approved_user)
    response_blob = make_esp_response_blob(question_key, esp_membership_id, response_values, submit_time)
    error = create_osp_form_response!(question_id, esp_membership_id, response_blob, submit_time)
    create_update_queue_row!(response_blob) if is_approved_user && !error.present?
    @render_error ||= error.present?
    error = create_nonOSP_response!(question_id, response_values, submit_time, esp_membership_id, is_approved_user, question_key)
    @render_error ||= error.present?
  end

  def make_esp_response_blob(question_key, esp_membership_id, response_values, submit_time)
    rvals = [*response_values].map do |response_value|
      {
          entity_state: params[:state],
          entity_id: @school.id,
          value: response_value,
          member_id: current_user.id,
          created: submit_time,
          esp_source: "osp"
      }.stringify_keys!
    end

    {question_key => rvals}.to_json
  end

  def make_nonOSP_response_blob(census_data_type, response_values, submit_time, esp_membership_id)
    rvals = [*response_values].map do |response_value|
      {
          entity_state: params[:state],
          entity_id: @school.id,
          entity_type: 'school',
          value: response_value,
          created: submit_time,
          member_id: esp_membership_id,
          source: 'manually entered by school official'
      }.stringify_keys!
    end

    {census_data_type => rvals}.to_json
  end

  def create_nonOSP_response!(question_id, response_values, submit_time, esp_membership_id, is_approved_user, question_key)
    begin
      data_type = OspData::ESP_KEY_TO_CENSUS_KEY[question_key] || OspData::ESP_KEY_TO_SCHOOL_KEY[question_key]
      if data_type.present?
        response_blob = make_nonOSP_response_blob(data_type, response_values, submit_time, esp_membership_id)
        create_osp_form_response!(question_id, esp_membership_id, response_blob, submit_time)
        create_update_queue_row!(response_blob) if is_approved_user
      end
    rescue => error
      GSLogger.error(:osp, error, vars: params, message: 'Didnt save osp response to update_queue and osp response table')
      error
    end
  end

  def create_osp_form_response!(osp_question_id, esp_membership_id, response, submit_time)
    begin
      error = OspFormResponse.create(
          osp_question_id: osp_question_id,
          esp_membership_id: esp_membership_id,
          school_id: @school.id,
          state: @school.state,
          response: response,
          updated: submit_time
      ).errors.full_messages

      GSLogger.error(:osp, nil, vars: params, message: "Didnt save osp response to osp_form_response table #{[*error].first}") if error.present?
      error

    rescue => e
      GSLogger.error(:osp, e, vars: params, message: 'Didnt save osp response to osp_form_response table')
      error.presence || ["An error occured"]
    end
  end

  def create_update_queue_row!(response_blob)
    begin
      error = UpdateQueue.create(
          source: :osp_form,
          priority: 2,
          update_blob: response_blob,
      ).errors.full_messages

      GSLogger.error(:osp, nil, vars: params, message: "Didnt save osp response to update_queue table #{[*error].first}") if error.present?
      error

    rescue => error
      GSLogger.error(:osp, error, vars: params, message: 'Didnt save osp response to update_queue table')
      error.presence || ["An error occured"]
    end
  end

  def render_osp_page
    gon.pagename = "Osp"
    gon.state_name = @state[:short]
    gon.omniture_pagename = GON_PAGE_NAME[params[:page]]
    data_layer_gon_hash.merge!({ 'page_name' => GON_PAGE_NAME[params[:page]] })
    set_omniture_data_for_school(gon.omniture_pagename)
    set_omniture_data_for_user_request
    set_meta_tags title: "Edit School Profile - #{PAGE_TITLE[params[:page]]} | GreatSchools"
    @parsley_defaults = "data-parsley-trigger=keyup data-parsley-blockhtmltags data-parsley-validation-threshold=0 "
    set_school_media_hashs_gon_var! #change to only appear on pages with the photo upload

    if db_page_name = DB_PAGE_NAME[params[:page]]
      @osp_display_config = OspDisplayConfig.find_by_page_and_school(db_page_name, @school)
      render "osp/osp_#{db_page_name}"
    else
      redirect_to my_account_url
    end
  end

  def render_success_js(image_id)
    render json: {success: 'Successfully Removed!', imageId: image_id}
  end

  def render_error_js
    render json: {error: 'Was not able to Remove'}
  end

  def set_school_media_hashs_gon_var!
    gon.school_media_hashes = SchoolMedia.school_media_hashes_for_osp(@school)
    gon.school_id = @school.id
  end

  ### BEFORE ACTIONS ###

  #think about making more generic and moving to application controller
  def set_osp_school_instance_vars
    if @state[:short].present? && params[:schoolId].present?
      @school = School.find_by_state_and_id(@state[:short], params[:schoolId])
      if @school.nil?
        redirect_to my_account_url
      elsif @school.active == 0 && !@school.demo_school?
        inactive_school_flash
        redirect_to my_account_url
      else
        @school
      end
    else
      redirect_to my_account_url #ToDo think of better redirect
    end
  end

  def set_esp_membership_instance_vars
    esp_membership = current_user.esp_membership_for_school(@school)
    if esp_membership.try(:approved?) || esp_membership.try(:provisional?)
      @esp_membership_id = esp_membership.id
      @is_approved_user = esp_membership.approved?
      notify_provisional_user! if esp_membership.provisional? && !request.xhr?
    else
      redirect_to my_account_url #ToDo think of better redirect
    end
  end

  def login_required_for_osp
    if @state[:short] == 'de'
      delaware_error_and_redirect_to(signin_path) unless logged_in?
    else
      login_required
    end
  end

  def validate_delaware_users
    if should_check_for_sso_token
      auth_cookie = get_auth_cookie
      return delaware_error_and_redirect_to(my_account_url) unless auth_cookie.present?

      auth_token = generate_auth_token(AUTH_SALT + current_user.email)
      unless auth_cookie == auth_token
        logger_vars = params.merge({gs_localAuth: cookies[AUTH_COOKIE_NAME], current_user_id: current_user.id, current_user_email: current_user.email})
        GSLogger.warn(:osp, nil, vars: logger_vars, message: 'gs_localAuth cookie failed authentication')
        return delaware_error_and_redirect_to(my_account_url)
      end
    end
  end

  def delaware_error_and_redirect_to(url)
    flash_notice t('forms.osp.delaware_error').html_safe
    redirect_to(url)
  end

  def get_auth_cookie
    auth_cookie = cookies[AUTH_COOKIE_NAME] || return
    auth_cookie.gsub('"', '').gsub(' ', '+') #removing " that were encoded in. And adding back + that were wrongly decoded
  end

  def generate_auth_token(string)
    Digest::MD5.base64digest(string)
  end

  def should_check_for_sso_token
    @state[:short] == 'de' && @school.public_or_charter? && !current_user.is_esp_superuser?
  end

  def notify_provisional_user!
    flash_notice t('forms.osp.provisional_user') unless flash_notice_include?(t('forms.osp.provisional_user'))
  end

  def success_or_error_flash
    @render_error ? flash_error(t('forms.osp.saving_error')) : flash_success(t('forms.osp.changes_saved'))
  end

  def inactive_school_flash
    flash_notice ("#{@school.name} may no longer exist. If you feel this is incorrect, please #{view_context.link_to('contact us', contact_us_path)}.").html_safe
  end

end

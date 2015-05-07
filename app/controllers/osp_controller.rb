class OspController < ApplicationController
  before_action :login_required, except: [:approve_provisional_osp_user_data]
  before_action :set_city_state
  before_action :set_footer_cities, except: [:approve_provisional_osp_user_data]
  before_action :set_osp_school_instance_vars, except: [:approve_provisional_osp_user_data]
  before_action :set_esp_membership_instance_vars, except: [:approve_provisional_osp_user_data]
  after_action :render_success_or_error, only: [:submit]

  PAGE_NAME = { '1' => 'GS:OSP:BasicInformation', '2' => 'GS:OSP:Academics', '3' => 'GS:OSP:Extracurriculars', '4' => 'GS:OSP:StaffFacilities'}
  PAGE_TITLE = {'1' => 'Basic Information', '2' => 'Academics', '3' => 'Extracurricular & Culture', '4' => 'Facilities & Staff'}

  def show
    @osp_data = OspData.new(@school) #add rescue here that shows nice error
    render_osp_page
  end

  def submit
    #If performance becomes an issue, look into making this a bulk single insert.
    submit_time = Time.now
    questions_and_answers.each do | (question_id, response_key, values) |
      save_response!(question_id, response_key, values, submit_time, @esp_membership_id, @is_approved_user)
    end
    redirect_to(:action => 'show',:state => params[:state], :schoolId => params[:schoolId], :page => params[:page])
  end

  #ToDo when Java is no longer the proxy, this should not be a route
  def approve_provisional_osp_user_data
    osp_form_responses = OspFormResponse.where(esp_membership_id: params[:membership_id])
    osp_form_responses.each do | osp_form_response |
      create_update_queue_row!(osp_form_response.response)
    end
    # only java is receiving this html, does not matter that it renders blank page
    render text: ''
  end

  protected

  def questions_and_answers
    params.except(:controller , :action , :page , :schoolId, :state, :utf8, :authenticy_token).map do | param, values |
      question_id, response_key = param.split('-', 2) rescue Rails.logger.error("error: invalid param #{param}") and next
      next unless values.present?
      validate_questions_and_answers(question_id.to_i, response_key, values)
    end.compact
  end

  def validate_questions_and_answers(question_id, response_key, response_values)
    #TODO add validation here to only allow questions/answers that a school is registered for
    #Validate based on question type and for open text use same validation logic as JS
    [question_id, response_key, [*response_values].uniq]
  end

  def save_response!(question_id, question_key, response_values, submit_time, esp_membership_id, is_approved_user)
    response_blob = make_response_blob(question_key, esp_membership_id, response_values, submit_time)

    error = create_osp_form_response!(question_id, esp_membership_id, response_blob)
    create_update_queue_row!(response_blob) if is_approved_user && !error.present?
    @render_error ||= error.present?
    #if this fails how do we reconcile the inconsistency of data because this isn't in school cache?
  end

  def make_response_blob(question_key, esp_membership_id, response_values, submit_time)
    rvals = response_values.map do |response_value|
      {
        entity_state: params[:state],
           entity_id: @school.id,
               value: response_value,
           member_id: esp_membership_id,
             created: submit_time,
          esp_source: "osp"
      }.stringify_keys!
    end

    {question_key => rvals}.to_json
  end

  def create_osp_form_response!(osp_question_id, esp_membership_id, response)
    begin
      error = OspFormResponse.create(
          osp_question_id: osp_question_id,
          esp_membership_id: esp_membership_id,
          response: response
      ).errors.full_messages

      Rails.logger.error "Didn't save osp response to osp_form_response table. error: \n #{error}" if error.present?
      error
        # todo need to fix with real validation
    rescue => error
      Rails.logger.error "Didn't save osp response to osp_form_response table. error: \n #{error}"
      error
    end
  end

  def create_update_queue_row!(response_blob)
    begin
      error = UpdateQueue.create(
          source: :osp_form,
          priority: 2,
          update_blob: response_blob,
      ).errors.full_messages

      Rails.logger.error "Didn't save osp response to update_queue table. error: \n #{error}" if error.present?
      error
        # todo need to fix with real validation
    rescue => error
      Rails.logger.error "Didn't save osp response to update_queue table. error: \n #{error}"
      error
    end
  end

  def render_osp_page
    gon.pagename = "Osp"
    gon.state_name = @state[:short]
    gon.omniture_pagename = PAGE_NAME[params[:page]]
    set_omniture_data_for_school(gon.omniture_pagename)
    set_omniture_data_for_user_request
    set_meta_tags title: "Edit School Profile - #{PAGE_TITLE[params[:page]]} | GreatSchools"
    @keyup = "data-parsley-trigger=keyup"

    if params[:page]== '1'
      @osp_display_config = OspDisplayConfig.find_by_page_and_school('basic_information', @school)
      render 'osp/osp_basic_information'
    elsif params[:page] == '2'
      @osp_display_config = OspDisplayConfig.find_by_page_and_school('academics', @school)
      render 'osp/osp_academics'
    elsif params[:page] == '3'
      @osp_display_config = OspDisplayConfig.find_by_page_and_school('extracurricular_culture', @school)
      render 'osp/osp_extracurricular_culture'
    elsif params[:page] == '4'
      @osp_display_config = OspDisplayConfig.find_by_page_and_school('facilities_staff', @school)
      render 'osp/osp_facilities_staff'
    else
      redirect_to my_account_url
    end
  end

  ### BEFORE ACTIONS ###

  #think about making more generic and moving to application controller
  def set_osp_school_instance_vars
    if @state[:short].present? && params[:schoolId].present?
      @school = School.find_by_state_and_id(@state[:short], params[:schoolId])
    else
      redirect_to my_account_url #ToDo think of better redirect
    end
  end

  def set_esp_membership_instance_vars
    esp_membership = current_user.esp_membership_for_school(@school)
    if esp_membership.try(:approved?) || esp_membership.try(:provisional?)
      @esp_membership_id = esp_membership.id
      @is_approved_user  = esp_membership.approved?
      notify_provisional_user! if esp_membership.provisional?
    else
      redirect_to my_account_url #ToDo think of better redirect
    end
  end

  def notify_provisional_user!
    flash_notice t('forms.osp.provisional_user') unless flash_notice_include?(t('forms.osp.provisional_user'))
  end

  def render_success_or_error
    @render_error ? flash_error(t('forms.osp.saving_error')) : flash_success(t('forms.osp.changes_saved'))
  end

end

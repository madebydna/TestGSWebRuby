class Admin::OspController < ApplicationController
  before_action :login_required
  before_action :set_city_state
  before_action :set_footer_cities
  before_action :set_osp_school_instance_vars
  before_action :set_esp_membership_instance_vars
  after_action :render_success_or_error, only: [:submit]
  SCHOOL_CACHE_KEYS = %w(esp_responses)


  def show
    @osp_form_data = OspFormResponse.find_form_data_for_school_state(params[:state],params[:schoolId])
    render_osp_page
  end

  def submit
    #ToDo probably should be more strict about validation than this
    #right now any param not in that list gets passed through.
    questionKeyParams = params.except(:controller , :action , :page , :schoolId, :state)

    #If performance becomes an issue, look into making this a bulk single insert.
    questionKeyParams.each do |question_key, answers|
      response_values = [*answers].select(&:present?).compact
      save_response!(question_key, @esp_membership_id, response_values) if response_values.present? #might want to wrap in rescue block
    end
    redirect_to(:action => 'show',:state => params[:state], :schoolId => params[:schoolId], :page => params[:page])
  end

  def save_response!(question_key, esp_membership_id, response_values)
    osp_question_id = OspQuestion.find_by_question_key(question_key).try(:id)
    osp_question_id or (Rails.logger.warn("Didn't save osp response. Couldn't find osp question key: #{question_key}") and return)

    response_blob = make_response_blob(question_key, esp_membership_id, response_values)

    error = create_osp_form_response!(osp_question_id, esp_membership_id, response_blob)
    create_update_queue_row!(response_blob) if @is_approved_user && !error.present?
    @render_error ||= error.present?
    #if this fails how do we reconcile the inconsistency of data because this isn't in school cache?
  end

  def make_response_blob(question_key, esp_membership_id, response_values)
    rvals = response_values.map do |response_value|
      {
        entity_state: params[:state],
           entity_id: @school.id,
               value: response_value,
           member_id: esp_membership_id,
             created: Time.now,
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

  def decorate_school(school)
    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    query = query.include_schools(school.state, school.id)
    query_results = query.query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    school_cache_results.decorate_schools([school]).first
  end


  def render_osp_page
    gon.pagename = "Osp"
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
      @school               = School.find_by_state_and_id(@state[:short], params[:schoolId])
      @school_with_esp_data = decorate_school(@school)
    else
      redirect_to my_account_url #ToDo think of better redirect
    end
  end

  def set_esp_membership_instance_vars
    esp_membership = current_user.esp_membership_for_school(@school)
    if esp_membership.try(:approved?) || esp_membership.try(:provisional?)
      @esp_membership_id = esp_membership.id
      @is_approved_user  = esp_membership.approved?
      notify_provisional_user if esp_membership.provisional?
    else
      redirect_to my_account_url #ToDo think of better redirect
    end
  end

  def notify_provisional_user
    flash_notice_has_not_been_set = !flash[:notice].try(:include?, t('forms.osp.provisional_user'))
    flash_notice t('forms.osp.provisional_user') if flash_notice_has_not_been_set
  end

  def render_success_or_error
    @render_error ? flash_error(t('forms.osp.saving_error')) : flash_success(t('forms.osp.changes_saved'))
  end

end

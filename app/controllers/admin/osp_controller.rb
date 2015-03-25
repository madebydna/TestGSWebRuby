class Admin::OspController < ApplicationController
  before_action :login_required
  before_action :set_city_state
  before_action :set_footer_cities
  SCHOOL_CACHE_KEYS = %w(esp_responses)


  def show
    @school = School.find_by_state_and_id(params[:state], params[:schoolId])
    @school_with_esp_data = decorate_school(@school)
    @osp_form_data = OspFormResponse.find_form_data_for_school_state(params[:state],params[:schoolId])
    if current_user.provisional_or_approved_osp_user?(@school)
      render_osp_page
    else
      redirect_to my_account_url
    end
  end


  def submit
    @school = School.find_by_state_and_id(params[:state], params[:schoolId])
    @school_with_esp_data = decorate_school(@school)
    #ToDo probably should be more strict about validation than this
    #right now any param not in that list gets passed through.
    questionKeyParams = params.except(:controller , :action , :page , :schoolId, :state)

    questionKeyParams.each do |key, vals|
      response_values = [*vals].select(&:present?).compact
      save_osp_from_row_per_question(key, response_values) if response_values.present?
    end

    redirect_to(:action => 'show',:state => params[:state], :schoolId => params[:schoolId], :page => params[:page])

  end

  def save_osp_from_row_per_question(key, response_values)
    osp_question_id   = OspQuestion.find_by_question_key(key).id
    esp_membership_id = current_user.esp_membership_for_school(@school).id
    response_blob     = make_response_blob(key, esp_membership_id, response_values)

    OspFormResponse.create(
      osp_question_id: osp_question_id,
      esp_membership_id: esp_membership_id,
      response: response_blob
    ).errors.full_messages
  end

  def make_response_blob(key, esp_membership_id, response_values)
    rvals = response_values.map do |response_value|
      {
       entity_state: params[:state],
          entity_id: @school.id,
              value: response_value,
          member_id: esp_membership_id,
            created: Time.now,
         esp_source: "osp_form"
      }.stringify_keys!
    end

    {key => rvals}.to_json
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


end
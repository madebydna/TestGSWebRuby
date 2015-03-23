class Admin::OspController < ApplicationController
  before_action :login_required
  before_action :set_city_state
  before_action :set_footer_cities
  SCHOOL_CACHE_KEYS = %w(esp_responses)


  def show
    @school = School.find_by_state_and_id(params[:state], params[:schoolId])
    @school_with_esp_data = decorate_school(@school)
    @osp_form_data = OspFormResponse.find_form_data_for_school_state(params[:state],params[:schoolId])
    @osp_form_data.values_for("before_after_care",@osp_form_data,@school_with_esp_data)
    # binding.pry;

    key = "before_after_care"

    if current_user.provisional_or_approved_osp_user?(@school)
      render_osp_page
    else
      redirect_to my_account_url
    end
  end


  def submit
    @school = School.find_by_state_and_id(params[:state], params[:schoolId])
    @school_with_esp_data = decorate_school(@school)
    questionKeyParams = params.except(:controller , :action , :page , :schoolId, :state)

    questionKeyParams.each_pair do |key, values|
      should_data_be_saved =false
      response_values = []
      values.each { |value|
        if value.present?
          should_data_be_saved = true
          response_values.push(value)
        end
        }
        if should_data_be_saved
          save_osp_from_row_per_question(key, response_values)
        end

    end
    redirect_to(:action => 'show',:state => params[:state], :schoolId => params[:schoolId], :page => params[:page])

  end

  def save_osp_from_row_per_question(key, response_values)
    osp_form_data = OspFormResponse.new
    osp_form_data.osp_question_id = OspQuestion.find_by_question_key(key).id
    esp_membership_id = current_user.esp_membership_for_school(@school).id
    osp_form_data.esp_membership_id = esp_membership_id
    response_json_rows = []
    response_values.each { |response_value|
      response_json_rows.push({"entity_state" => params[:state], "entity_id" => @school.id, "value" => response_value, "member_id" => esp_membership_id, "created" => Time.now , "esp_source" => "osp_form"})

    }
    response_set = {key => response_json_rows}
    osp_form_data.response = response_set.to_json
    osp_form_data.save!
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
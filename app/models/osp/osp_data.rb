#encapsulates 'osp' data about a school that can be modified on the osp form page
#represents data from osp_form_responses and school_cache tables, but may include census tables in the future
class OspData

  attr_accessor :cachified_school, :osp_form_responses

  SCHOOL_CACHE_KEYS = %w(characteristics esp_responses)

  CENSUS_KEY_TO_ESP_KEY = {'student_enrollment' => 'Enrollment' , 'administrator_name' => 'Head official name' , 'administrator_email' => 'Head official email address'}

  SCHOOL_KEY_TO_ESP_KEY = {'address' => 'street' , 'grade_served' => 'level' , 'school_url' => 'home_page_url'}



  def initialize(school)
    @cachified_school = decorate_school(school)
    #probably should be doing a unique/distinct in mysql. Also if in ruby, may want to add limit
    @osp_form_responses = OspFormResponse.for_school(school).order(:osp_question_id, updated: :desc).to_a
  end

  def values_for(key, question_id)
    begin
      key = key.to_s
      census_key = CENSUS_KEY_TO_ESP_KEY[key]
      school_key = SCHOOL_KEY_TO_ESP_KEY[key]
      osp_response_values = most_recent_osp_form_response(key, question_id)
      if census_key.present?
        school_cache_values_from_census_data  = cachified_school.characteristcs_value_by_name(census_key, grade: nil, number_value: false).to_s.split(',')
        if osp_response_values.present? && school_cache_values_from_census_data.present?
          cachified_school.created_time(census_key) > osp_response_values[:created_at] ? school_cache_values_from_census_data : osp_response_values[:values]
        else
          osp_response_values.present? ? osp_response_values[:values] : school_cache_values_from_census_data
        end
      elsif school_key.present?
        school_value  = cachified_school.school.send(school_key).split(',') #will return empty array if no results
        modified_time = cachified_school.school.modified
        if osp_response_values.present? && school_value.present?
          modified_time > osp_response_values[:created_at] ? school_value : osp_response_values[:values]
        else
          osp_response_values.present? ? osp_response_values[:values] : school_value
        end
      else
        school_cache_values  = cachified_school.values_for(key) #will return empty array if no results
        if osp_response_values.present? && school_cache_values.present?
          cachified_school.created_time_for(key) > osp_response_values[:created_at] ? school_cache_values : osp_response_values[:values]
        else
          osp_response_values.present? ? osp_response_values[:values] : school_cache_values
        end

      end


    rescue => error
      Rails.logger.error "Can't get values for q_id: #{question_id}; key: #{key}; school: #{cachified_school.state}, #{cachified_school.id}; error: \n #{error}"
      []
    end
  end


  private


  def decorate_school(school)
    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    query = query.include_schools(school.state, school.id)
    query_results = query.query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    school_cache_results.decorate_school(school)
  end

  def most_recent_osp_form_response(response_key, question_id)
    osp_form_responses.each do | osp_form_response |
      if osp_form_response.osp_question_id == question_id &&  (osp_form_response.response)[response_key] == response_key
        values = JSON.parse(osp_form_response.response)[response_key]
        created_at = Time.parse(values.first['created'])
        values.map! { |value| value['value'] }

        return values.present? ? {created_at: created_at, values: values} : nil
      end
    end
    nil
  end

end
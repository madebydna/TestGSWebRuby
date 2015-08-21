class CommunityScorecardData

  attr_accessor :school_data_params

  SCHOOL_CACHE_KEYS = 'characteristics'

  def initialize(school_data_params={})
    @school_data_params = school_data_params
  end

  def scorecard_data
    {
      school_data: school_data,
      header_data: header_data,
      more_results: solr_response[:more_results]
    }
  end

  def school_data
    # TODO We need to sort through the school data to get the most recent year
    # and reject all data that isn't that year.
    @school_data ||= (
      school_data = solr_response[:school_data]
      cachified_schools = get_cachified_schools(school_data)

      cachified_schools.map { | cs | SchoolDataHash.new(cs, school_data_hash_options).data_hash }
    )
  end

  def solr_response
    @solr_response ||= SchoolDataService.school_data(school_data_service_params)
  end

  def header_data
    school_info_header = {data_type: I18n.t(:school_info, scope: t_scope)}
    school_data.each_with_object([school_info_header]) do |sd, hd|
      sd.each do |data_type, value_hash|
        if (state_average = value_hash[:state_average]).present?
          hd << {
            param: data_type,
            data_type: I18n.t(data_type, scope: t_scope),
            state_average: I18n.t(:state_average, val: state_average, scope: t_scope),
          }
        end
      end
    end.uniq
  end

  #Todo later when solr layer is built, add appropriate whitelisting for solr params here or in school_data_service where necessary
  def school_data_service_params
    school_data_params
  end

  def school_data_hash_options
    @options ||= {
      data_sets:  school_data_params[:data_sets], #['graduation_rate', 'a_through_g'],
      sub_group_to_return: school_data_params[:sortBreakdown], #asian
    }
  end

  def get_cachified_schools(school_data)
    grouped_schools = get_schools_grouped_by_state(school_data)

    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    grouped_schools.each { | state, schools | query.include_schools(state, schools.map(&:id)) }
    query_results = query.query

    schools = grouped_schools.values.flatten
    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    cachified_schools = school_cache_results.decorate_schools(schools)

    sort_schools_by_school_data(school_data, cachified_schools)
  end

  def sort_schools_by_school_data(school_data, schools)
    #make hash using state & school_id as key
    schools = schools.each_with_object({}) { |s, h| h[[s.state.downcase, s.id]] = s }

    #reorder schools to order thats in school_data
    school_data.map { |sd| schools[[sd.state.downcase, sd.school_id]] }
  end

  def get_schools_grouped_by_state(school_data)
    school_data_grouped_by_state = school_data.group_by { |sd| sd.state }

    school_data_grouped_by_state.each_with_object({}) do | (state, sd_array), h | #bulk query for all schools
      ids = sd_array.map(&:school_id)
      h[state] = School.on_db(state).where(id: ids).to_a
    end
  end

  protected

  def t_scope
    'models.schools.community_scorecard_data'
  end
end

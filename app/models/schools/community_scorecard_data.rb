class CommunityScorecardData

  attr_accessor :school_data_params

  SCHOOL_CACHE_KEYS = 'characteristics'

  #Todo replace these with real ids
  DATA_SET_TO_ID_MAP = {
    graduation_rate: 1,
    a_through_g: 2
  }.stringify_keys!


  def initialize(school_data_params={})
    @school_data_params = school_data_params
  end

  def get_school_data
    school_data = temp_school_data_service(school_data_service_params)
    cachified_schools = get_cachified_schools(school_data)

    cachified_schools.map { | cs | SchoolDataHash.new(cs, school_data_hash_options).data_hash }
  end

  #Todo later when solr layer is built, add appropriate whitelisting for solr params here or in school_data_service where necessary
  def school_data_service_params
    school_data_params
  end

  def school_data_hash_options
    @options ||= {
      data_sets:  school_data_params[:data_sets], #['graduation_rate', 'a_through_g'],
      sub_group_to_return: school_data_params[:sub_group_filter], #asian
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

  #fake layer to be replaced by the school data service
  def temp_school_data_service(fake_params)
    school_data_struct = Struct.new(:school_id, :state)
    [
      school_data_struct.new(19, 'ca'),
      school_data_struct.new(1, 'ca'),
      school_data_struct.new(6397, 'ca')
    ]
  end

end

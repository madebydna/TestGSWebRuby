class CommunityScorecardData

  attr_accessor :school_data_params

  SCHOOL_CACHE_KEYS = ['characteristics', 'performance']

  def initialize(school_data_params={})
    @collection = Collection.find(school_data_params[:collectionId])
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
    @school_data ||= (
      school_data = solr_response[:school_data]
      cachified_schools = get_cachified_schools(school_data)

      cachified_schools.map do | cs |
        data_hash = SchoolDataHash.new(cs, school_data_hash_options).data_hash
        add_data_explanations!(data_hash)
      end
    )
  end

  def solr_response
    @solr_response ||= SchoolDataService.school_data(school_data_service_params)
  end

  def header_data
    h_data = school_data.each_with_object([]) do |sd, hd|
      sd.each do |data_type, value_hash|
        if (state_average = value_hash[:state_average]).present?
          hd << {
            param: data_type,
            data_type: I18n.t(data_type, scope: collection_t_scope),
            state_average: I18n.t(:state_average, val: state_average, scope: t_scope),
          }
        end
      end
    end.uniq

    validate_header_data(h_data)
  end

  def validate_header_data(h_data)
    #ensure data types are there
    validated_header_data = data_set_with_year_map.keys.map do | data_set |
      hd = h_data.find { |hd| hd[:param].to_s == data_set.to_s }
      next hd if hd.present?

      {
        param: data_set,
        data_type: I18n.t(data_set, scope: collection_t_scope),
        state_average: I18n.t(:state_average_not_available, scope: t_scope),
      }
    end

    validated_header_data.unshift({data_type: I18n.t(:school_info, scope: collection_t_scope)}) #school info
  end

  def add_data_explanations!(data_hash)
    data_explanations.each do |data_type, explanation|
      if data_hash[data_type]
        data_hash[data_type][:explanation] = explanation
      end
    end
    data_hash
  end

  def data_explanations
    data_set_with_year_map.keys.each_with_object({}) do |data_type, h|
      h[data_type.to_sym] = I18n.t("#{data_type}_explanation_html", scope: collection_t_scope)
    end
  end

  def school_data_service_params
    school_data_params.merge({
      sortYear: data_set_with_year_map[school_data_params[:sortBy]]
    })
  end

  def school_data_hash_options
    @options ||= {
      data_sets_and_years: data_set_with_year_map,
      sub_group_to_return: school_data_params[:sortBreakdown], #asian
      link_helper:         school_data_params[:link_helper]
    }
  end

  # For example: ['graduation_rate' => '2013, 'a_through_g' => '2014'],
  def data_set_with_year_map
    @data_set_with_year_map ||= data_sets_with_years(school_data_params[:data_sets])
  end

  def data_sets_with_years(data_sets)
    data_sets_and_years = @collection.scorecard_fields.map do |field|
      unless field[:data_type].to_s == 'school_info'
        [field[:data_type], field[:year]]
      end
    end.compact
    data_set_to_year = Hash[data_sets_and_years].with_indifferent_access

    data_set_to_year.keep_if { |k,_| [*data_sets].include? k.to_s }
  end

  def get_cachified_schools(school_data)
    schools = schools_from_school_data(school_data)
    school_cache_results = SchoolCache.cached_results_for(schools, SCHOOL_CACHE_KEYS)
    cachified_schools = school_cache_results.decorate_schools(schools)

    sort_schools_by_school_data(school_data, cachified_schools)
  end

  def sort_schools_by_school_data(school_data, schools)
    #make hash using state & school id as key
    schools = schools.each_with_object({}) { |s, h| h[[s.state.downcase, s.id]] = s }

    #reorder schools to order thats in school_data
    school_data.map { |sd| schools[[sd.state.downcase, sd.id]] }
  end

  def schools_from_school_data(school_data)
    school_data_grouped_by_state = school_data.group_by { |sd| sd.state }

    school_data_grouped_by_state.each_with_object([]) do | (state, sd_array), a | #bulk query for all schools
      a.push(*School.on_db(state).where(id: sd_array.map(&:id)).to_a)
    end
  end

  protected

  def t_scope
    'models.schools.community_scorecard_data'
  end

  def collection_t_scope
    "#{t_scope}.collection_id_#{@collection.id}"
  end
end

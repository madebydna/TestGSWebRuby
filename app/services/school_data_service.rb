# encoding: utf-8

class SchoolDataService
  @@solr = Solr.new

  DEFAULT_SOLR_OPTIONS = {rows: 10, query: '*:*', fq: ['+document_type:school_data']}

  PARAMETER_TO_SOLR_MAPPING = {
    collectionId: 'sd_collection',
    gradeLevel: 'sd_school_grade_level',
    offset: :start,
    sortBy: :sort,
  }

  #there are underscores at the end because a breakdown will get appended ie, 'white', 'female'
  SORT_VALUE_MAP = Hash.new('sd_school_id').merge!({
    graduation_rate: 'sd_4_year_high_school_graduation_rate_',
    a_through_g: 'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_'
  }).with_indifferent_access

  SORT_BREAKDOWN_MAP = Hash.new('').merge!({
    white:                             'White',
    asian:                             'Asian',
    native_american_or_native_alaskan: 'Native_American_or_Native_Alaskan',
    pacific_islander:                  'Pacific_Islander',
    all_students:                      'All_students',
    multiracial:                       'Multiracial',
    filipino:                          'Filipino',
    hispanic:                          'Hispanic',
    african_american:                  'African_American',
    male:                              'Male',
    female:                            'Female',
    not_economically_disadvantaged:    'Not_economically_disadvantaged',
    students_with_disabilities:        'Students_with_disabilities',
    general_education_students:        'General_Education_students',
    economically_disadvantaged:        'Economically_disadvantaged',
    limited_english_proficient:        'Limited_English_proficient',
    not_limited_english_proficient:    'Not_limited_English_proficient'
  }).with_indifferent_access

  SORT_ASC_OR_DESC = Hash.new('_sortable_asc asc').merge!({
    asc: '_sortable_asc asc',
    desc: ' desc',
  }).with_indifferent_access

  class << self

    def school_data(options_params = {})
      options = base_options(options_params, PARAMETER_TO_SOLR_MAPPING)
      options.merge!(get_sort(options_params))
      filters = extract_filters(options_params)
      param_options = DEFAULT_SOLR_OPTIONS.merge(options)

      param_options[:fq] = DEFAULT_SOLR_OPTIONS[:fq].clone
      filters.each { |filter| param_options[:fq] << filter }

      parse_school_results(get_results param_options)

    end

    def extract_filters(filters)
      filter_arr = []
      filter_hash = {
          collectionId: "+sd_collection_id:#{filters[:collectionId]}",
          gradeLevel: "+sd_school_grade_level:(#{filters[:gradeLevel]})"
      }

      filter_hash.each do |k, v|
        if filters[k].present?
          filter_arr << v
        end
      end
      filter_arr
    end

    def get_results(options)
      @@solr.get_search_results options
    end

    def base_options(hash, key_map)
      key_map.inject({}) do |h, (k, v)|
        hash[k].present? ? h.merge(v => hash[k]) : h
      end
    end

    def remap_value(hash, key, value_map)
      hash[key] = value_map[hash[key]] if hash.include? key
    end

    def get_sort(hash)
      hash.include?(:sortBy) ? {sort: extract_sort_type(hash) + SORT_ASC_OR_DESC[hash[:sortAscOrDesc]]} : {}
    end

    def extract_sort_type(options)
      SORT_VALUE_MAP[options[:sortBy]] + SORT_BREAKDOWN_MAP[options[:sortBreakdown]]
    end

    def parse_school_results(solr_results)
      school_data_struct = Struct.new(:school_id, :state)
      solr_results['response']['docs'].map do |school_search_result|
        school_data_struct.new(school_search_result['sd_school_id'], school_search_result['sd_school_database_state'].first)
      end
    end
  end
end

# encoding: utf-8

class SchoolDataService
  @@solr = Solr.new

  extend SchoolDataValidator

  BASE_PARAMS = {
    offset: :start,
  }

  PROCESS_VALUES_MAP = Hash.new(proc { nil }).merge!({
    start:        proc { |value| value.present? ? value.try(:to_i) : nil },
    collectionId: proc { |value| value.present? ? value.try(:to_i) : nil },
    gradeLevel:   proc { |value| ['h','m','e','p'].include?(value) ? value : nil },
    schoolType:   proc do |value|
                    school_type = ['public', 'charter', 'private'] & [*value]
                    school_type.present? ? school_type.join(' ') : nil
                  end
  })

  DEFAULT_SOLR_OPTIONS = {rows: 10, query: '*:*'}
  DEFAULT_SOLR_FILTER_QUERY = ['+document_type:school_data']

  FILTER_MAP = {
    collectionId: "+sd_collection_id:",
    gradeLevel: "+sd_school_grade_level:",
    schoolType: "+sd_school_type:"
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

  DEFAULT_SORT = 'sd_school_id asc'

  class << self

    def school_data(options_params = {})
      options = base_options(options_params, BASE_PARAMS)
      options.merge!(sort_params(options_params))
      options = DEFAULT_SOLR_OPTIONS.merge(options)
      options[:fq] = DEFAULT_SOLR_FILTER_QUERY + extract_filters(options_params)

      parse_solr_results(get_results options)
    rescue => error
      GSLogger.error(:community_spotlight, error, vars: options)
      { school_data: [] }
    end

    private

    def extract_filters(filters)
      FILTER_MAP.each_with_object([]) do | (param_key, solr_key), filter_map |
        validated_value = PROCESS_VALUES_MAP[param_key].call(filters[param_key])
        filter_map << "#{solr_key}(#{validated_value})" if validated_value.present?
      end
    end

    def get_results(options)
      @@solr.get_search_results options
    end

    #remap keys to solr keys & validate values
    def base_options(hash, key_map)
      key_map.inject({}) do |h, (param_key, solr_key)|
        validated_value = PROCESS_VALUES_MAP[solr_key].call(hash[param_key])
        validated_value.present? ? h.merge(solr_key => validated_value) : h
      end
    end

    def remap_value(hash, key, value_map)
      hash[key] = value_map[hash[key]] if hash.include? key
    end

    def sort_params(hash)
      if hash.include?(:sortBy) && hash.include?(:sortYear)
        sort = extract_sort_type(hash)
        sort << "_#{hash[:sortYear]}"
        processed_sort = is_valid_school_data_field?(sort) ? (sort + SORT_ASC_OR_DESC[hash[:sortAscOrDesc]]) : DEFAULT_SORT
        {sort: processed_sort}
      else
        {}
      end
    end

    def extract_sort_type(options)
      SORT_VALUE_MAP[options[:sortBy]] + SORT_BREAKDOWN_MAP[options[:sortBreakdown]]
    end

    def parse_solr_results(solr_results)
      # for now we only need 2 fields from solr, will make into a class when appropriate
      school_data_struct = Struct.new(:school_id, :state)
      solr_response = solr_results['response']
      school_data = solr_response['docs'].map do |school_search_result|
        school_id = school_search_result['sd_school_id']
        state = school_search_result['sd_school_database_state'].first
        school_data_struct.new(school_id, state)
      end
      {
        school_data: school_data,
        more_results: more_results?(solr_response)
      }
    end

    def more_results?(solr_response)
      (solr_response['numFound'] - solr_response['start']) > DEFAULT_SOLR_OPTIONS[:rows]
    end
  end
end

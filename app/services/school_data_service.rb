# encoding: utf-8

class SchoolDataService
  @@solr = Solr.new

  BASE_PARAMS_MAP = {
    offset: :start,
  }

  VALIDATION_CALLBACKS = Hash.new(proc { nil }).merge!({
    start:        proc { |value| value.present? ? value.try(:to_i) : nil },
    collectionId: proc { |value| value.present? ? value.try(:to_i) : nil },
    gradeLevel:   proc { |value| ['h','m','e'].include?(value) ? value : nil },
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

  class << self

    # ex options_params
    # {
    #   'collectionId'  => '15',
    #   'offset'        => '0',
    #   'gradeLevel'    => 'h',
    #   'sortBy'        => 'a_through_g',
    #   'sortBreakdown' => 'asian',
    #   'sortAscOrDesc' => 'asc',
    #   'schoolType'    => ['public', 'charter'],
    #   'link_helper'   => controller_object
    # }
    def school_data(options_params = {})
      options = parse_options(options_params)
      parse_solr_results(get_results(options), options[:rows])
    rescue => error
      GSLogger.error(:community_spotlight, error, vars: options)
      { school_data: [] }
    end

    private

    def parse_options(options_params={})
      options = base_options(options_params)
      options.merge!(sort_params(options_params))
      options = DEFAULT_SOLR_OPTIONS.merge(options)
      options.merge(fq: DEFAULT_SOLR_FILTER_QUERY + filter_params(options_params))
    end

    #remap keys to solr keys & validate values
    def base_options(options_hash={})
      BASE_PARAMS_MAP.each_with_object({}) do |(param_key, solr_key), base_opts|
        validated_value = VALIDATION_CALLBACKS[solr_key].call(options_hash[param_key])
        base_opts.merge!(solr_key => validated_value) if validated_value.present?
      end
    end

    #extract filters & validate values
    def filter_params(options_hash)
      FILTER_MAP.each_with_object([]) do | (param_key, solr_key), filter_map |
        validated_value = VALIDATION_CALLBACKS[param_key].call(options_hash[param_key])
        filter_map << "#{solr_key}(#{validated_value})" if validated_value.present?
      end
    end

    def sort_params(options_hash={})
      SchoolDataSortBuilder.new(options_hash).school_data_sort
    end

    def get_results(options)
      @@solr.get_search_results options
    end

    def parse_solr_results(solr_results, num_of_rows = DEFAULT_SOLR_OPTIONS[:rows])
      # for now we only need 2 fields from solr, will make into a class when appropriate
      school_data_struct = Struct.new(:id, :state)
      solr_response = solr_results['response']
      school_data = solr_response['docs'].map do |school_search_result|
        school_id = school_search_result['sd_school_id']
        state = school_search_result['sd_school_database_state'].first
        school_data_struct.new(school_id, state)
      end
      {
        school_data: school_data,
        more_results: more_results?(solr_response, num_of_rows)
      }
    end

    def more_results?(solr_response, num_of_rows)
      (solr_response['numFound'] - solr_response['start']) > num_of_rows
    end
  end
end

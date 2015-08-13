# encoding: utf-8

class SchoolDataService
  @@solr = Solr.new

  DEFAULT_SOLR_OPTIONS = {rows: 10, query: '*', fq: ['+document_type:school']}


  PARAMETER_TO_SOLR_MAPPING = {
      collection: 'collection',
      data_type: 'data_type', #TODO: handle, bug htouw
      grade: 'grade',
      offset: :start,
      sort_type: 'sort_type'
  }

  SORT_VALUE_MAP= {} #TODO fill this in please, bug htouw

  class << self

    def school_data(options_param = {})
      options = options_param.deep_dup
      rename_keys(options, PARAMETER_TO_SOLR_MAPPING)
      remap_sort(options)
      filters = extract_filters(options)
      param_options = DEFAULT_SOLR_OPTIONS.merge(options)
      param_options[:fq] = DEFAULT_SOLR_OPTIONS[:fq].clone
      filters.each { |filter| param_options[:fq] << filter }

      parse_school_results(get_results param_options)

    end

    def extract_filters(filters)
      filter_arr = []
      filter_hash = {
          collection: "+collection_id:#{filters[:collection]}",
          grade: "+grades:(#{filters[:grade]})"
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

    def rename_keys(hash, key_map)
      key_map.each do |k, v|
        hash[v] = hash[k]
        hash.delete k
      end
    end

    def remap_value(hash, key, value_map)
      hash[key] = value_map[hash[key]] if hash.include? key
    end

    def remap_sort(hash)
      remap_value(hash, :sort, SORT_VALUE_MAP)
    end

    def parse_school_results(solr_results)
      school_data_struct = Struct.new(:school_id, :state)
      solr_results['response']['docs'].map do |school_search_result|
        school_data_struct.new(school_search_result['school_id'], school_search_result['state'])
      end

    end
  end
end
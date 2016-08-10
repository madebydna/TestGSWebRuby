require 'active_support/concern'

module CachedCategoryDataConcerns
  extend ActiveSupport::Concern
  include CensusLoading::Subjects

  # Returns all data from school cache for the category's category_data's data
  # types.
  #
  # The return value is a hash with array keys of the format
  # [data_type, subject_id] pointing to an array of value hashes.
  #
  # Note: this method only works on caches that are built using the CacheFormat
  # module, which standardizes structure, e.g. the Characteristics and
  # Performance caches.
  def cached_data_for_category(with_subjects = true)
    category_data_types = category_data_key_map(with_subjects).values.uniq
    get_cache_data(category_data_types)
  end

  def get_cache_data(desired_data_types)
    Array.wrap(desired_data_types).each_with_object({}) do |data_type_hash, hash|
      data_type = data_type_hash[:data_type]
      if (values = all_school_cache_data[data_type])
        if (subject = data_type_hash[:subject])
          data = values.select { |v| convert_subject_to_id(v[:subject]) == subject }
          if data.present?
            hash[[data_type, subject]] = data
          end
        else
          hash[[data_type, nil]] = values
        end
      end
    end
  end

  #changes data to something like:
  #{ ["GreatSchools Rating", "GreatSchools Rating", nil]=>
  #    [{breakdown: 'all_students'...}, {breakdown: 'asian'...}, {breakdown: 'white'...}],
  #  ["SomeOtherSchoolCacheKey", "SomeOtherSchoolCacheKey", nil]=>
  #    [{breakdown: 'all_students'...}, {breakdown: 'asian'...}, {breakdown: 'white'...}],
  #}
  #the key is an array [school_cache_key, translated_school_cache_key, subject_id]
  def transform_data_keys
    category.category_data.each_with_object({}) do | cd, new_data |
      data_key = category_data_school_cache_map[cd]
      if (value_hash = data[data_key]).present?
        new_data.merge!({[cd.label(false), cd.label, data_key.last] => value_hash.deep_dup})
      end
    end
  end

  def transform_data_keys!
    self.data = transform_data_keys
  end

  def select_breakdown_with_label(values, label, &block)
    breakdown = config[:breakdown_mappings].try(:[], label) || 'all students'
    breakdown_matcher = Proc.new do |d|
      d[:breakdown].try(:downcase) == breakdown.try(:downcase)
    end
    values.select(&breakdown_matcher)
  end

  protected

  def all_school_cache_data
    @_all_school_cache_data ||= begin
      school_cache_results = SchoolCache.cached_results_for(school, self.class::SCHOOL_CACHE_KEYS)
      decorated_school = school_cache_results.decorate_schools(school).first
      decorated_school.merged_data.symbolize_keys
    end.deep_dup
  end

  # Example return value:
  # { category_data_object => [:'GreatSchools Rating', nil] }
  def category_data_school_cache_map
    category_data_key_map.each_with_object({}) do |(cd, key_map), map|
      map[cd] = key_map.values
    end
  end

  # Example return value:
  # {
  #   category_data_object => {
  #     data_type: 'GreatSchools Rating',
  #     subject: nil
  #   },
  #   another_category_data_object => {
  #     data_type: 'Test score rating',
  #     subject: nil
  #   }
  # }
  def category_data_key_map(with_subjects = true)
    category.category_data.inject({}) do |cd_key_map, cd|
      key = if with_subjects
              { data_type: cd.response_key.to_sym, subject: cd.subject_id }
            else
              { data_type: cd.response_key.to_sym }
            end
      cd_key_map.merge({ cd => key })
    end
  end
end

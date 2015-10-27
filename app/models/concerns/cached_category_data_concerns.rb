require 'active_support/concern'

module CachedCategoryDataConcerns
  extend ActiveSupport::Concern
  include CensusLoading::Subjects

  def cached_data_for_category(category = category, with_subjects = true)
    category_data_types = category_data_key_map(category, with_subjects).values.uniq
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

  def all_school_cache_data
    @_all_school_cache_data ||= begin
      school_cache_results = SchoolCache.cached_results_for(school, school_cache_keys)
      decorated_school = school_cache_results.decorate_schools(school).first
      decorated_school.merged_data.symbolize_keys
    end
  end

  def preserve_data_type_name(opts = {})
    prefix = opts[:prefix] || 'all:'
    translated_label_map = category.key_label_map(true, true)
    untranslated_label_map = category.key_label_map(false, true)
    data.each do |key, _|
      key = label_lookup_value(key)
      config["#{prefix}#{translated_label_map[key]}"] = untranslated_label_map[key]
    end
  end

  def change_data_type_to_label
    data.transform_keys! do |key|
      label = category.key_label_map(true, true)[label_lookup_value(key)]
      [label, key.last]
    end
  end

  def label_lookup_value(key)
    [key.first.to_s, key.last]
  end

  def category_data(category = category)
    category.category_data(school.collections)
  end

  #ex return value {category_data_object => { data_type: 'GreatSchools Rating', subject: nil }, another_category_data_object => {data_type: 'Test score rating', subject: nil}
  def category_data_key_map(category = category, with_subjects = true)
    category_data(category).inject({}) do |cd_key_map, cd|
      key = if with_subjects
              { data_type: cd.response_key.to_sym, subject: cd.subject_id }
            else
              { data_type: cd.response_key.to_sym }
            end
      cd_key_map.merge({ cd => key })
    end
  end

  #ex return value { category_data_object => [:'GreatSchools Rating', nil] }
  def get_category_data_school_cache_map(category = category, with_subjects = true)
    category_data_key_map.each_with_object({}) do |(cd, key_map), map|
      map[cd] = key_map.values
    end
  end

  #changes data to something like:
  #{ ["GreatSchools Rating", "GreatSchools Rating", nil]=>
  #    [{breakdown: 'all_students'...}, {breakdown: 'asian'...}, {breakdown: 'white'...}],
  #  ["SomeOtherSchoolCacheKey", "SomeOtherSchoolCacheKey", nil]=>
  #    [{breakdown: 'all_students'...}, {breakdown: 'asian'...}, {breakdown: 'white'...}],
  #}
  #the key is an array [school_cache_key, translated_school_cache_key, subject_id]
  def transform_data_keys(c_data = category_data)
    c_data.each_with_object({}) do | cd, new_data |
      data_key = category_data_school_cache_map[cd]
      if (value_hash = data[data_key]).present?
        new_data.merge!({[cd.label(false), cd.label, data_key.last] => value_hash.deep_dup})
      end
    end
  end

  #defaults to matching for all students
  def breakdown_data_for(label)
    breakdown = config[:breakdown_mappings].try(:[], label) || 'all students'
    Proc.new { |d| d[:breakdown].try(:downcase) == breakdown.try(:downcase) }
  end

  def select_breakdown_with_label(values, label, &block)
    breakdown_matcher = breakdown_data_for(label)
    values.select(&breakdown_matcher).map(&block)
  end

end

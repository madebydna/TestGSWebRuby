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
end

require 'active_support/concern'

module CachedCategoryDataConcerns
  extend ActiveSupport::Concern
  include CensusLoading::Subjects

  def cached_data_for_category(category = category, with_subjects = true)
    category_data_types = category.category_data(school.collections).map do |cd|
      if with_subjects
        { data_type: cd.response_key.to_sym, subject: cd.subject_id }
      else
        { data_type: cd.response_key.to_sym }
      end
    end
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
          hash[data_type] = values
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

end

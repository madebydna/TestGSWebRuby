require 'active_support/concern'

module CachedCategoryDataConcerns
  extend ActiveSupport::Concern

  def cached_data_for_category(category = category)
    category_data_types = category.keys(school.collections).map do |key|
      key.respond_to?(:to_sym) ? key.to_sym : key
    end
    get_cache_data(category_data_types)
  end

  def get_cache_data(desired_keys)
    all_school_cache_data.select { |k,v| [*desired_keys].include?(k) }.deep_dup
  end

  def all_school_cache_data
    @_all_school_cache_data ||= begin
      school_cache_results = SchoolCache.cached_results_for(school, school_cache_keys)
      decorated_school = school_cache_results.decorate_schools(school).first
      decorated_school.merged_data.symbolize_keys
    end
  end

end

require 'active_support/concern'

module CachedCategoryDataConcerns
  extend ActiveSupport::Concern

  def cached_data_for_category(category, cache_key, school)
    category_data_types = category.keys(school.collections).map do |key|
      key.respond_to?(:to_sym) ? key.to_sym : key
    end
    get_cache_data(cache_key, category_data_types, school)
  end

  def get_cache_data(cache_key, desired_keys, school)
    SchoolCache.send("cached_#{cache_key}_data", school).select do |k,v|
      # TODO Make this generic so that it works for all caches
      [*desired_keys].include?(k) || [*desired_keys].include?(CensusDataType.data_type_id_for_data_type_label(k))
    end
  end

end

require 'active_support/concern'

module CachedCategoryDataConcerns
  extend ActiveSupport::Concern

  def cached_data_for_category(category, cache_key, school)
    category_data_types = category.keys(school.collections).map do |key|
      key.respond_to?(:to_sym) ? key.to_sym : key
    end
    SchoolCache.send("cached_#{cache_key}_data", school).select do |k,v|
      # TODO Make this generic so that it works for all caches
      category_data_types.include?(k) || category_data_types.include?(CensusDataType.data_type_id_for_data_type_label(k))
    end
  end
end

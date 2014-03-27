class CategoryData < ActiveRecord::Base
  attr_accessible :category_id, :category, :collection_id, :collection, :response_key, :source, :sort_order, :label
  has_paper_trail
  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns
  belongs_to :category

  # return CategoryData with collection_id in the provided
  # collections. If a single object is passed in, the Array(...) call will convert it to an array
  # Will return CategoryData with nil collection_id
  def self.belonging_to_collections(category, collections = nil)
    all_data_for_category(category).select do |category_data|
      array_of_ids_with_nil = (Array(collections).map(&:id))<<nil
      array_of_ids_with_nil.include? category_data.collection_id
    end
  end

  def self.all_data_for_category(category)
    cache_key = "all_data_for_category-category_id:#{category.name}"
    Rails.cache.fetch(cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
      order('category_id asc').order('collection_id desc').where(category_id:category.id).all
    end
  end

  def possible_sources
    SchoolProfileDataReader.data_readers
  end

end

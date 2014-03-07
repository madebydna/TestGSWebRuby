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
    Rails.cache.fetch("#{SchoolProfileConfigCaching::CATEGORY_DATA_PER_CATEGORY_PREFIX}#{category.name.gsub(/\s+/,'_')}", expires_in: 5.minutes) do
      order('category_id asc').order('collection_id desc').where(category_id:category.id).all
    end
  end

  def possible_sources
    CategoryDataReader.sources
  end

end

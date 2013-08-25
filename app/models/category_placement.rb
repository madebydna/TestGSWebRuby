class CategoryPlacement < ActiveRecord::Base
  attr_accessible :category, :collection, :page, :position, :category_id, :collection_id, :page_id

  belongs_to :category
  belongs_to :collection
  belongs_to :page


  # return CategoryPlacements with collection_id in the provided
  # collections. If a single object is passed in, the Array(...) call will convert it to an array
  # Will return CategoryPlacements with nil collection_id
  def self.belonging_to_collections(page, collections = nil)
    placements_for_page(page).select do |category_placement|
      array_of_ids_with_nil = (Array(collections).map(&:id))<<nil
      array_of_ids_with_nil.include? category_placement.collection_id
    end
  end

  def self.placements_for_page(page)
    Rails.cache.fetch("CategoryPlacement/page_#{page.name.gsub(/\s+/,'_')}", expires_in: 5.minutes) do
      order('position asc').order('collection_id desc').where(page_id:page.id)
    end
  end

end

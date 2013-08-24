class CategoryPlacement < ActiveRecord::Base
  attr_accessible :category, :collection, :page, :position, :category_id, :collection_id, :page_id

  belongs_to :category
  belongs_to :collection
  belongs_to :page

  # scope belonging_to_collections as a query that will return CategoryPlacements with collection_id in the provided
  # collections. If a single object is passed in, the Array(...) call will convert it to an array
  scope :belonging_to_collections, ->(collections) { where(collection_id: Array(collections).map(&:id)) }

end

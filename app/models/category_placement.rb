class CategoryPlacement < ActiveRecord::Base
  attr_accessible :category, :collection, :page, :position, :category_id, :collection_id, :page_id

  belongs_to :category
  belongs_to :collection
  belongs_to :page

end

class CategoryData < ActiveRecord::Base
  attr_accessible :category_id, :category, :collection_id, :collection, :response_key, :response_label

  belongs_to :collection
  belongs_to :category
end

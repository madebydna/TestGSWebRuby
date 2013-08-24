class Category < ActiveRecord::Base
  attr_accessible :description, :name, :parent

  has_many :category_placements, :order => 'collection_id desc'

  belongs_to :parent, :class_name => 'Category'
  has_many :categories, :foreign_key => 'parent_id'
end

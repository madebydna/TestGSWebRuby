class Page < ActiveRecord::Base
  attr_accessible :name, :parent

  has_many :category_placements

  belongs_to :parent, :class_name => 'Page'
  has_many :pages, :foreign_key => 'parent_id'
end

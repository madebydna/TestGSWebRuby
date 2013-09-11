class Collection < ActiveRecord::Base
  attr_accessible :description, :name
  has_paper_trail

  has_many :school_collections, :order => 'collection_id desc'
  has_many :schools, through: :school_collections
end

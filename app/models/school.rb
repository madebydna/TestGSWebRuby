class School < ActiveRecord::Base
  attr_accessible :name, :state

  has_many :school_collections
  has_many :collections, through: :school_collections
  has_many :school_category_datas
end

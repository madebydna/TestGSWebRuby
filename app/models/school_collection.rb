class SchoolCollection < ActiveRecord::Base
  attr_accessible :collection, :school, :collection_id, :school_id

  belongs_to :school
  belongs_to :collection
end

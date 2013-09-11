class SchoolCategoryData < ActiveRecord::Base
  attr_accessible :key, :school, :school_data, :school_id

  belongs_to :school
end

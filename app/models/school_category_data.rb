class SchoolCategoryData < ActiveRecord::Base
  attr_accessible :active, :category, :key, :school, :value, :value_type

  belongs_to :school
  belongs_to :category

end

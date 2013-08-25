class SchoolCategoryData < ActiveRecord::Base
  attr_accessible :active, :key, :school, :value

  belongs_to :school
  belongs_to :category

end

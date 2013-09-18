class SchoolCategoryData < ActiveRecord::Base
  attr_accessible :key, :school, :school_data, :school_id, :state

  belongs_to :school

  def school=(school)
    school_id = school.id
    state = school.state
  end

  def school
    School.using(state.upcase.to_sym).find school_id
  end

end

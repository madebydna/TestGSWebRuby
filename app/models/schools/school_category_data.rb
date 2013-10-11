class SchoolCategoryData < ActiveRecord::Base
  attr_accessible :key, :schools, :school_data, :school_id, :state
  include StateSharding

  belongs_to :school

  def school=(school)
    school_id = school.id
    state = school.state
  end

  def school
    School.on_db(state.downcase.to_sym).find school_id
  end

end

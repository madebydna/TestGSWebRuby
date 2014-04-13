class SchoolProfileDataReader

  attr_accessor :school

  delegate :page, to: :school

  def initialize(school)
    @school = school
  end

end
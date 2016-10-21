class SchoolUserDigest

  SECRET = 343788

  attr_reader :member_id, :school

  def initialize(member_id, school)
    @member_id = member_id
    @school = school
  end

  def create
    return nil unless @member_id && school
    Digest::MD5.base64digest("#{SECRET}#{school.id}#{school.state}#{@member_id}")
  end
end

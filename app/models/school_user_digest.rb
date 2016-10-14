class SchoolUserDigest

  SECRET = 343788

  attr_reader :user, :school

  def initialize(user, school)
    @user = user
    @school = school
  end

  def create
    return nil unless user && school
    Digest::MD5.base64digest("#{SECRET}#{school.id}#{school.state}#{user.id}")
  end
end

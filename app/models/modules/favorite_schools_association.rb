module FavoriteSchoolsAssociation
  def self.included(base)
    base.class_eval do
      has_many :favorite_schools, foreign_key: 'member_id'
    end
  end

  def add_favorite_school!(school)
    favorite_school = FavoriteSchool.build_for_school school
    favorite_schools << favorite_school
    favorite_school.save!
  end

  def favorited_school?(school)
    favorite_schools.any? { |favorite| favorite.school_id == school.id && favorite.state == school.state }
  end
  alias_method :favored_school?, :favorited_school?

end
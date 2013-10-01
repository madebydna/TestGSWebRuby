class SchoolRating < ActiveRecord::Base
  octopus_establish_connection(:adapter => "mysql2", :database => "surveys")

  self.table_name='school_rating'

  def self.fetch_reviews(school)
    # TODO: restrict reviews to correct statuses
    SchoolRating.where(school_id: school.id, state: school.state).order('posted DESC').all
  end

end
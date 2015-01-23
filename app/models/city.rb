class City < ActiveRecord::Base
  self.table_name = 'city'

  db_magic :connection => :us_geo

  attr_accessible :population, :bp_census_id, :name, :state

  scope :active, -> { where(active: true) }

  def self.popular_cities(state, options = {})
    result = where(state: state, active: 1).order('population desc')
    result = result.limit(options[:limit]) if options[:limit]
    result.to_a.sort { |c1, c2| c1.name <=> c2.name }
  end

  def state_long
    States.abbreviation_hash[state.downcase]
  end

  def display_name
    state == 'DC' ? "Washington, DC" : name
  end

  def schools_by_rating_desc
    @schools_by_rating_desc ||= (
      schools = School.within_city(self.state, self.name)

      School.preload_school_metadata!(schools)

      # If the school doesn't exist in the top_school_ids array,
      # then sort it to the end
      schools.sort do |s1, s2|
        if s1.great_schools_rating == s2.great_schools_rating
          0
        elsif s1.great_schools_rating.nil?
          1
        elsif s2.great_schools_rating.nil?
          -1
        else
          s2.great_schools_rating.to_i <=> s1.great_schools_rating.to_i
        end
      end
    )
  end
end

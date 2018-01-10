class City < ActiveRecord::Base
  self.table_name = 'city'

  db_magic :connection => :us_geo

  attr_accessible :population, :bp_census_id, :name, :state
  attr_reader :rating

  scope :active, -> { where(active: true) }

  def self.popular_cities(state, options = {})
    result = where(state: state, active: 1).order('population desc')
    result = result.limit(options[:limit]) if options[:limit]
    result.to_a.sort { |c1, c2| c1.name <=> c2.name }
  end

  # used by the widget
  def self.get_city_by_name(city)
    City.where(name:city).active
  end

  # used by the widget
  def self.get_city_by_name_and_state(city, state)
    City.where(name:city, state:state).active
  end

  def state_long
    States.abbreviation_hash[state.downcase]
  end

  def display_name
    state == 'DC' ? "Washington, DC" : name
  end

  def county
    @county ||= County.find_by(state: state, FIPS: fipsCounty)
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

  module CollectionMethods
    def preload_ratings
      return self unless present?

      make_key = Proc.new { |state, city| "#{state}_#{city}" }
      states = map(&:state)

      key_to_city_rating_map = states.each_with_object({}) do |state, accum|
        ratings = CityRating.having_max_year_in_state(state)
        ratings.each do |city_rating|
          accum[make_key.call(state, city_rating.city)] = city_rating.rating
        end
      end

      each do |city|
        city.instance_variable_set(
          :@rating,
          key_to_city_rating_map[
            make_key.call(city.state, city.name)
          ]
        )
      end

      self
    end
  end
end

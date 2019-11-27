class City < ActiveRecord::Base
  self.table_name = 'city'

  db_magic :connection => :us_geo

  SCHOOL_CACHE_KEYS = %w(characteristics)

  attr_accessible :id, :population, :bp_census_id, :name, :state
  attr_reader :rating

  scope :active, -> { where(active: true) }

  def self.popular_cities(state, options = {})
    result = where(state: state, active: 1).order('population desc')
    result = result.limit(options[:limit]) if options[:limit]
    options[:by_size] ? result.to_a : result.to_a.sort_by(&:name)
  end

  # used by the widget
  def self.get_city_by_name(city)
    cities = City.where(name:city).active
    return cities.first if cities.length == 1
  end

  # used by the widget
  def self.get_city_by_name_and_state(city, state)
    City.find_by(name: city, state: States.abbreviation(state), active: 1)
  end

  def self.get_all_cities
    City.all.order(id: :asc).active
  end

  def self.cities_in_state(state)
    City.where(state: state).active.order('name')
  end

  def self.find_neighbors(city)
    select_sql = <<~SQL
      id, name, state, (
      6371 * acos (
      cos ( radians(:lat) )
      * cos( radians(lat) )
      * cos( radians(lon) - radians(:lon) )
      + sin ( radians(:lat) )
      * sin( radians(lat) )
      )
      ) AS distance
    SQL
    City.select(sanitize_sql_array([select_sql, lat: city.lat, lon: city.lon]))
      .where(state: city.state, active: true)
      .where.not(id: city.id)
      .having("distance < 100") # 100 km =~ 62.1371 miles
      .order("distance").limit(8)
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

  def schools_within_city
    @_schools_within_city ||= begin
      School.within_city(self.state, self.name).active
    end
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

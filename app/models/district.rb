class District < ActiveRecord::Base
  self.table_name = 'district'
  include StateSharding
  attr_accessible :FIPScounty, :active, :charter_only, :city, :county, :created, :fax, :home_page_url, :lat, :level, :level_code, :lon, :mail_city, :mail_street, :mail_zipcode, :manual_edit_by, :manual_edit_date, :modified, :modifiedBy, :name, :nces_code, :notes, :num_schools, :phone, :state, :state_id, :street, :street_line_2, :type_detail, :zipcentroid, :zipcode
  has_many :schools

  scope :active, -> { where(active: true) }

  def self.find_by_state_and_name(state, name)
    District.on_db(state).where(name: name).active.first rescue nil
  end
  
  def city_record
    City.get_city_by_name_and_state(city, state).first
  end

  def self.find_by_state_and_ids(state, ids = [])
    District.on_db(state.downcase.to_sym).
      where(id: ids).active
  end

  def self.ids_by_state(state)
    District.on_db(state.downcase.to_sym).active.order(:id).select(:id).map(&:id)
  end

  def boilerplate_object
    @boilerplate_object ||= DistrictBoilerplate.find_for_district(self).first
  end

  def state_level_boilerplate_object
    @state_level_boilerplate_object ||= DistrictStateLevelBoilerplate.find_for_district(self).first
  end

  def nearby_districts
    nearby_district_objects = 
      NearbyDistrict.find_by_district(self).sorted_by_distance

    neighbor_ids = nearby_district_objects.map(&:neighbor_id)
    districts = District.find_by_state_and_ids(state, neighbor_ids)
    districts.sort_by { |d| neighbor_ids.index(d.id) }
  end

  # Returns numeric value or nil
  # Memoizes its result
  def rating
    @rating ||= (
      district_rating_object = DistrictRating.for_district(self)
      district_rating_object.present? ? district_rating_object.rating : nil
    )
  end

  def schools_by_rating_desc
    @district_schools_by_rating_desc ||= (
      schools = School.within_district(self)

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

  def self.by_number_of_schools_desc(state,city)
    District.on_db(state.downcase.to_sym).active.where(city: city.name).order(num_schools: :desc)
  end

  def self.query_distance_function(lat, lon)
    miles_center_of_earth = 3959
    "(
    #{miles_center_of_earth} *
     acos(
       cos(radians(#{lat})) *
       cos( radians( `lat` ) ) *
       cos(radians(`lon`) - radians(#{lon})) +
       sin(radians(#{lat})) *
       sin( radians(`lat`) )
     )
   )".squish
  end

end

class District < ActiveRecord::Base
  self.table_name = 'district'
  include StateSharding
  attr_accessible :FIPScounty, :active, :charter_only, :city, :county, :created, :fax, :home_page_url, :lat, :level, :level_code, :lon, :mail_city, :mail_street, :mail_zipcode, :manual_edit_by, :manual_edit_date, :modified, :modifiedBy, :name, :nces_code, :notes, :num_schools, :phone, :state, :state_id, :street, :street_line_2, :type_detail, :zipcentroid, :zipcode
  has_many :schools

  def self.find_by_state_and_name(state, name)
    District.on_db(state).where(name: name).first rescue nil
  end

  def boilerplate_object
    @boilerplate_object ||= DistrictBoilerplate.find_for_district(self).first
  end

  def state_level_boilerplate_object
    @state_level_boilerplate_object ||= DistrictStateLevelBoilerplate.find_for_district(self).first
  end

  def nearby_districts
    nearby_district_objects = 
      NearbyDistrict.where(
        district_state: self.state.downcase,
        district_id: self.id
      ).order('distance asc')
    neighbor_ids = nearby_district_objects.map(&:neighbor_id)
    districts = District.on_db(state.downcase.to_sym).where(id: neighbor_ids)
    districts.sort_by { |d, value| neighbor_ids.index(d.id) }
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
      schools = School.on_db(state.downcase.to_sym).
        where(district_id: id).
        all

      school_metadata = SchoolMetadata.on_db(state.downcase.to_sym).
        where(
          school_id: schools.map(&:id),
          meta_key: 'overallRating'
        ).to_a

      school_metadata.sort_by! { |metadata| metadata.meta_value.to_i }
      school_metadata.reverse!
      top_school_ids = school_metadata.map(&:school_id)
      schools.select { |school| top_school_ids.include? school.id }
    )
  end

end

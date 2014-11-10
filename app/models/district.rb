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

end

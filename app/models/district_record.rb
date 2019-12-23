class DistrictRecord < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  attr_accessible :state, :district_id, :state_id, :city, :county, :FIPScounty, :fax, :home_page_url, :lat, :lon, 
  :name, :nces_code, :num_schools, :phone, :street, :zipcode, :level_code, :level, :mail_street, 
  :mail_city, :mail_zipcode, :zipcentroid, :type_detail, :active, :street_line_2, 
  :charter_only, :created, :modified

  # unique_id is composite of state and district_id, e.g. ca-1
  primary_key = 'unique_id'

  # invokes the unique_id getter 
  before_validation :unique_id, on: :create 

  validates :state, :district_id, :state_id, :city, :county, :fax, :home_page_url,
  :name, :nces_code, :phone, :street, :zipcode, :level_code, :level, :mail_street, 
  :mail_city, :mail_zipcode, presence: true
  validates :district_id, uniqueness: { scope: :state }, on: :create

  scope :by_state, ->(state) { where(state: state) }
  scope :active, -> { where(active: true) }

  def unique_id
    self[:unique_id] ||= "#{self.state}-#{self.district_id}"
  end

  def self.ids_by_state(state)
    by_state(state).pluck(:district_id)
  end

  def self.find_by_state_and_ids(state, ids = [])
    by_state(state.downcase).
      where(district_id: ids).active
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

  def self.update_from_district(district, state)
    dr = self.find("#{state}-#{district.id}")
    dr ||= self.new(unique_id: "#{state}-#{district.id}", state: state.to_s, district_id: district.id)
    dr.assign_attributes(
      district.attributes.symbolize_keys.except(
      :id, # id is already set as district_id
      :state, # District#state is returned as uppercase
      # these fields don't exist in district_records
      :modifiedBy, 
      :manual_edit_by, 
      :manual_edit_date, 
      :notes)
    )
    dr.save
  end

    def city_record
      City.get_city_by_name_and_state(city, state)
    end

end
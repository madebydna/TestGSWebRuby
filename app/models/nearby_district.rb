class NearbyDistrict < ActiveRecord::Base
  self.table_name = 'NearbyDistrict'
  db_magic :connection => :gs_schooldb

  def self.find_by_district(district)
    NearbyDistrict.where(
      district_state: district.state.downcase,
      district_id: district.id
    )
  end

  scope :sorted_by_distance, -> { order('distance asc') }

end

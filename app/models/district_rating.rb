class DistrictRating < ActiveRecord::Base
  include StateSharding
  self.table_name = 'district_rating'

  scope :active, -> { where(active: true) }

  def self.for_district(district)
    on_db(district.state.downcase.to_sym).
      active.
      where(district_id: district.id).
      first
  end

end
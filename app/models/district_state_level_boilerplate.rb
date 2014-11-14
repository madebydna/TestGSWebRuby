class DistrictStateLevelBoilerplate < ActiveRecord::Base
  self.table_name = 'district_state_level_boilerplate'
  db_magic :connection => :gs_schooldb

  def self.find_for_district(district)
    where(state: district.state.downcase)
  end

end
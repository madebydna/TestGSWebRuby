class DistrictBoilerplate < ActiveRecord::Base
  self.table_name = 'district_boilerplate'
  db_magic :connection => :gs_schooldb

  def self.find_for_district(district)
    where(state: district.state.downcase, district_id: district.id)
  end

end
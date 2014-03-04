class ZillowRegionId < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  self.table_name='zillow_region_id'

  def self.by_school(school)
     by_city_state(school.city, school.state)
  end

  def self.by_city_state(city, state)
    region = ZillowRegionId.where(city: city, state: States.abbreviation(state).upcase).first
    region ? region.region_Id : nil
  end

  def self.data_for(city, state)
    Rails.cache.fetch("zillow_data-city:#{city}-state:#{state}") do
      {
        'zillow_formatted_location' => city.downcase.gsub(/ /, '-') + '-'+ state[:short],
        'region_id' => ZillowRegionId.by_city_state(city, state[:long])
      }
    end
  end
end

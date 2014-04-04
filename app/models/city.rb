class City < ActiveRecord::Base
  self.table_name = 'city'

  db_magic :connection => :us_geo

  attr_accessible :population, :bp_census_id

  scope :active, where(active: true)

  def self.popular_cities(state, options = {})
    result = where(state: state, active: 1).order('population desc')
    result = result.limit(options[:limit]) if options[:limit]
    result
  end

  def state_long
    States.abbreviation_hash[state.downcase]
  end

  def formatted_name
    "#{name}, #{state}"
  end
end

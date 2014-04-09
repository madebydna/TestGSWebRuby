class City < ActiveRecord::Base
  self.table_name = 'city'

  db_magic :connection => :us_geo

  attr_accessible :population, :bp_census_id, :name, :state

  scope :active, where(active: true)

  def self.popular_cities(state, options = {})
    # Fix the thing
    result = where(state: state, active: 1).order('population desc')
    result = result.limit(options[:limit]) if options[:limit]
    result.reorder('name asc')
  end

  def state_long
    States.abbreviation_hash[state.downcase]
  end
end

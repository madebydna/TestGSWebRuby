class City < ActiveRecord::Base
  self.table_name = 'city'

  db_magic :connection => :us_geo

  attr_accessible :population, :bp_census_id, :name, :state

  scope :active, -> { where(active: true) }

  def self.popular_cities(state, options = {})
    result = where(state: state, active: 1).order('population desc')
    result = result.limit(options[:limit]) if options[:limit]
    result.to_a.sort { |c1, c2| c1.name <=> c2.name }
  end

  def state_long
    States.abbreviation_hash[state.downcase]
  end

  def display_name
    state == 'DC' ? "Washington, DC" : name
  end
end

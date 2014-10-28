class StateHomeDecorator < Draper::Decorator
  decorates :hash

  NUMBER_OF_CITIES_IN_SHORT_LIST = 20
  NUMBER_OF_COLUMNS_OF_CITIES = 4
  NUMBER_OF_DISTRICTS_IN_SHORT_LIST = 20
  NUMBER_OF_COLUMNS_OF_DISTRICTS = 4

  def state_hash
    hash
  end

  def abbreviation
    state_hash[:short]
  end

  def name
    state_hash[:long].gs_capitalize_words
  end

  def approximate_schools_in_state
    real_count = School.on_db(abbreviation.to_sym).where(active: true).count
    real_count.round(-2)
  end

  def cities_list
    @cities_list ||= City.where(state: abbreviation, active: true).
      order('population desc').limit(NUMBER_OF_CITIES_IN_SHORT_LIST).in_groups(NUMBER_OF_COLUMNS_OF_CITIES, false)
  end

  def districts_list
    @districts_list ||= Array(District.on_db(abbreviation.to_sym).where(active: true).
      order('num_schools desc').limit(NUMBER_OF_CITIES_IN_SHORT_LIST)).in_groups(NUMBER_OF_COLUMNS_OF_DISTRICTS, false)
  end

end
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
    state_hash[:long].gs_capitalize_first
  end

  def approximate_schools_in_state
    real_count = School.on_db(abbreviation.to_sym).where(active: true).count
    real_count.round(-2)
  end

  def all_cities
    @all_cities ||= 
      City.where(state: abbreviation, active: true).order('name asc')
  end

  def short_cities_list
    short_list = all_cities.sort do |c1, c2|
      c2.population.to_i <=> c1.population.to_i
    end[0..NUMBER_OF_CITIES_IN_SHORT_LIST-1]
    short_list.in_groups(NUMBER_OF_COLUMNS_OF_CITIES, false)
  end

  def expanded_cities_list
    if all_cities.size > NUMBER_OF_CITIES_IN_SHORT_LIST
      all_cities.in_groups(NUMBER_OF_COLUMNS_OF_CITIES, false)
    else
      []
    end
  end

  def number_of_cities
    all_cities.size
  end

  def number_of_districts
    all_districts.size
  end

  def all_districts
    District.on_db(abbreviation.to_sym).where(active: true).order('name asc')
  end

  def short_districts_list
    all_districts[0..NUMBER_OF_DISTRICTS_IN_SHORT_LIST-1].
      in_groups(NUMBER_OF_COLUMNS_OF_DISTRICTS, false)
  end

  def expanded_districts_list
    if all_districts.size > NUMBER_OF_DISTRICTS_IN_SHORT_LIST
      all_districts.in_groups(NUMBER_OF_COLUMNS_OF_DISTRICTS, false)
    else
      []
    end
  end

end
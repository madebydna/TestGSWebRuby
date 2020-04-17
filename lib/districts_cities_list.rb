class DistrictsCitiesList

  attr_reader :state

  def initialize(state)
    @state = state
  end

  def city_names
    @_cities ||= (
      City.where(active: 1, state: state).order(name: :asc).pluck(:name)
    )
  end

  def districts_cities_counties
    @_districts_cities_counties ||= (
      DistrictRecord.by_state(state.downcase)
        .order(:name)
        .select(:unique_id, :name, :district_id, :state, :city, :county)
        .map(&:serializable_hash)
    )
  end

  def state_name_long
    States.state_name(state)
  end

  def state_names
    {
        long: state_name_long,
        full: state_name_long.titleize,
        abbr: state,
        routing: state_route
    }
  end

  def state_route
    if state == 'DC'
      'Washington_DC'
    else
      state_name_long.titleize.gsub(' ','_')
    end
  end

  def dropdown_info
    States.labels_hash.map{ |k,v| [k.upcase, v.gsub(' ','_')] }.to_h.sort
  end

end
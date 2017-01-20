class DistrictsCitiesList

  attr_reader :state

  def initialize(state)
    @state = state
  end

  def cities(state)
    @_cities ||= (
      City.where(active: 1, state: state).order(name: :asc).pluck(:name)
    )
  end

  def districts_cities_counties(state)
    @_districts_cities_counties ||= (
      District.on_db(state.downcase.to_sym)
        .where(active: 1)
        .order(name: :asc)
        .select(:name, :city, :county).to_a
        .map(&:serializable_hash)
    )
  end

  def state_full_name(state)
    States.state_name(state).titleize
  end

  def state_names(state)
    {
        full: state_full_name(state),
        abbr: state,
        routing: state_full_name(state).gsub(' ','_')
    }
  end

  def dropdown_info
    States.labels_hash.map{ |k,v| [k.upcase, v ]}.to_h
  end

end
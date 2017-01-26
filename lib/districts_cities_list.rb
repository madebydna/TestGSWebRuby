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
      District.on_db(state.downcase.to_sym)
        .where(active: 1)
        .order(name: :asc)
        .select(:name, :city, :county).to_a
        .map(&:serializable_hash)
    )
  end

  def state_full_name
    States.state_name(state).titleize
  end

  def state_names
    {
        full: state_full_name,
        abbr: state,
        routing: state_full_name.gsub(' ','_')
    }
  end

  def dropdown_info
    States.labels_hash.map{ |k,v| [k.upcase, v.gsub(' ','_')] }.to_h.sort
  end

end
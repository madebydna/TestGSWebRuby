class DistrictsListController < ApplicationController

  layout 'application'

  def show
    @districts_cities_counties = districts_cities_counties(state_names[:abbr])
    @state_names = state_names
    @dropdown_info = dropdown_info
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

  def dcl
    @_dcl ||= DistrictsCitiesList.new(state)
  end

  def state_full_name
    States.state_name(params[:state_name]).titleize
  end

  def state_names
    {
        full: state_full_name,
        abbr: params[:state_name],
        routing: state_full_name.gsub(' ','_')
    }
  end

  def dropdown_info
    States.labels_hash.map{ |k,v| [k.upcase, v ]}.to_h
  end

end
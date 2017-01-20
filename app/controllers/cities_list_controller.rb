class CitiesListController < ApplicationController

  layout 'application'

  before_filter :require_valid_state

  def show
    @cities = cities(state_names[:abbr])
    @state_names = state_names
    @dropdown_info = dropdown_info
  end

  def cities(state)
    @_cities ||= (
      City.where(active: 1, state: state).order(name: :asc).pluck(:name)
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

  def require_valid_state
    unless States.abbreviations.include?(params[:state_name].downcase)
    # if school.blank?
      render "error/page_not_found", layout: "error", status: 404
    end
  end

end
class DistrictsListController < ApplicationController

  layout 'application'

  before_filter :require_valid_state

  def show
    @districts_cities_counties = dcl.districts_cities_counties(state)
    @state_names = dcl.state_names(state)
    @dropdown_info = dcl.dropdown_info
  end

  def state
    params[:state_name]
  end

  def dcl
    @_dcl ||= DistrictsCitiesList.new(state)
  end

  def require_valid_state
    unless States.abbreviations.include?(state.downcase)
      render "error/page_not_found", layout: "error", status: 404
    end
  end

end
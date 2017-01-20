class CitiesListController < ApplicationController

  layout 'application'

  before_filter :require_valid_state

  def show
    gon.pageTitle = meta_title
    set_meta_tags title: meta_title
    @cities = dcl.cities(state)
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

  def meta_title
    "#{dcl.state_full_name(state)} School information by City: Popular Cities"
  end

end
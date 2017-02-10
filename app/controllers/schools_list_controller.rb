class SchoolsListController < ApplicationController
  def show
    state = params[:state_abbr].downcase
    if States.abbreviations.include?(state.downcase)
      redirect_to state_path(state: gs_legacy_url_encode(States.state_name(state))), :status => :moved_permanently
    else
      redirect_to home_path, :status => :moved_permanently
    end
  end
end
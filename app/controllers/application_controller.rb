class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all
  # Finds school given request param schoolId
  def find_school
    state = params[:state] || 'ca'
    state.gsub! '-', ' '
    state_abbreviation = States.abbreviation(state)
    school_id = params[:schoolId].to_i || 1

    if school_id.nil?
      # todo: redirect to school controller, school_not_found action
    end

    @school = School.on_db(state_abbreviation.downcase.to_sym).find school_id
  end
end

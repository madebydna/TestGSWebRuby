class SchoolProfilesController < ApplicationController
  protect_from_forgery
  before_filter :require_school

  layout "application"

  def show
    @school = school
    @school_profile = school_profile
  end

  private

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(school_params[:state_abbr], school_params[:id])
  end

  def school_profile
    @_school_profile ||= (
      OpenStruct.new.tap do |sp|
        sp.hero = hero
      end
    )
  end

  def school_params
    params.permit(:schoolId, :school_id, :state)
    params[:id] = params[:schoolId] || params[:school_id]
    params[:state_abbr] = States.abbreviation(params[:state])
    params
  end

  def require_school
    if school.blank?
      render "error/school_not_found", layout: "error", status: 404
    end
  end

  def hero
    SchoolProfiles::Hero.new(
      school,
      school_cache_data_reader: SchoolProfiles::SchoolCacheDataReader.new(school)
    )
  end

end

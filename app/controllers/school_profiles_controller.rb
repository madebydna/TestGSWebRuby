class SchoolProfilesController < ApplicationController
  protect_from_forgery
  before_filter :require_school

  layout "application"

  def show
    @school = school
    @breadcrumbs = breadcrumbs
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
        sp.test_scores = test_scores
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

  def test_scores
    SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: SchoolProfiles::SchoolCacheDataReader.new(school)
    )
  end

  def breadcrumbs
    school = SchoolProfileDecorator.decorate(@school)
    {
      school.state_breadcrumb_text => state_url(state_params(school.state)),
      school.city_breadcrumb_text => city_url(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.schools') => search_city_browse_url(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.school_profile') => nil
    }
  end
end

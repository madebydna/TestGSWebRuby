class SchoolProfilesController < ApplicationController
  protect_from_forgery
  before_filter :require_school

  layout "application"

  def show
    @school = school
    @breadcrumbs = breadcrumbs
    @school_profile = school_profile
    @school_profile_decorator = SchoolProfileDecorator.decorate(@school)
    school_gon_obj(@school)
    add_gon_links
    add_gon_ethnicity
  end

  private

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(get_school_params[:state_abbr], get_school_params[:id])
  end

  def school_profile
    @_school_profile ||= (
      OpenStruct.new.tap do |sp|
        sp.hero = hero
        sp.test_scores = test_scores
        sp.college_readiness = college_readiness
        sp.reviews = reviews
        sp.review_questions = review_questions
        sp.ethnicity = ethnicity
      end
    )
  end

  def get_school_params
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

  def school_cache_data_reader
    @_school_cache_data_reader ||=
      SchoolProfiles::SchoolCacheDataReader.new(school)
  end

  def hero
    SchoolProfiles::Hero.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def test_scores
    SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: school_cache_data_reader 
    )
  end

  def college_readiness
    SchoolProfiles::CollegeReadiness.new(
      school_cache_data_reader: school_cache_data_reader 
    )
  end

  def ethnicity
    SchoolProfiles::EthnicityData.new(
        school_cache_data_reader: school_cache_data_reader
    )
  end

  def reviews
    SchoolProfiles::Reviews.new(school.reviews)
  end

  def review_questions
    SchoolProfiles::ReviewQuestions.new(school)
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

  def school_gon_obj(school)
    if school.present?
      gon.school = {
          :id => school.id,
          :state => school.state
      }
    end
  end

  def add_gon_ethnicity
    gon.ethnicity = ethnicity.data_values
  end

  def add_gon_links
    gon.links = {
        terms_of_use: terms_of_use_path,
        school_review_guidelines: school_review_guidelines_path,
        session: api_session_path
    }
  end
end

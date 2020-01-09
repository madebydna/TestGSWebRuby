class SimpleAjaxController < ApplicationController
  include ApplicationHelper
  include AuthenticationConcerns
  protect_from_forgery

  layout false

  def get_cities_alphabetically
    response = {}
    state = params[:state]
    @cities = City.popular_cities(state, alphabetical: true) if state.present?
    response = @cities.map(&:name) if @cities.present?

    respond_to do |format|
      format.json { render json: response}
    end
  end

  def get_schools_with_link
    response = {}
    osp = params[:osp]
    state_param = params[:state]
    city = params[:city]
    state = States.abbreviation(state_param) if state_param.present?
    @schools = School.within_city(state,city) if state.present? && city.present?
    response = @schools.to_a.map do |school|
      {id:school.id,
       name: school.name,
       url: osp == 'true' ? osp_registration_path(city: city, state: state, schoolId: school.id) : school_path(school) }
    end

    respond_to do |format|
      format.json { render json: response}
    end
  end

 def build_schools_review_path(school)
   path = school_reviews_path(school)
   if params[:morganstanley].present?
     path += "?morganstanley=1"
   end
   if params[:topic_id].present?
     path += "#topic" + params[:topic_id]
   end
   path
 end

end

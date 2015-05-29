class SimpleAjaxController < ApplicationController
  include ApplicationHelper
  include AuthenticationConcerns
  protect_from_forgery

  layout false

  def get_cities
    response = {}
    state = params[:state]
    @cities = City.popular_cities(state) if state.present?
    response = @cities.map(&:name) if @cities.present?

    respond_to do |format|
      format.json { render json: response}
    end
  end

  def get_schools
    response = {}
    state_param = params[:state]
    city = params[:city]
    state = States.abbreviation(state_param) if state_param.present?

    @schools = School.within_city(state,city) if state.present? && city.present?
    response = @schools.to_a.map { |school| {id:school.id, name: school.name} }

    respond_to do |format|
      format.json { render json: response}
    end
  end

  def get_school_and_forward
    school_id = params[:school_id]
    state = params[:state]

    school = School.find_by_state_and_id(state,school_id)
    if school.present?
      redirect_to (build_schools_review_path(school))
    else
      render 'error/school_not_found', layout: 'error', status: 404
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

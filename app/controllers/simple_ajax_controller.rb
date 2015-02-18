class SimpleAjaxController < ApplicationController
  include ApplicationHelper
  include AuthenticationConcerns
  protect_from_forgery

  layout false

  def create_helpful_review
    helpful_id = params[:helpful_id]
    review_id = params[:review_id]
    if(helpful_id.present? && helpful_id.to_i > 0 )
      HelpfulReview.find_by(id: helpful_id).toggle!(:active)
      respond_to do |format|
        format.json { render json:  HelpfulReview.helpful_counts_by_id(review_id).merge({'helpful_id'=>helpful_id})}
      end
      # exit
    elsif review_id.numeric?
      ip = remote_ip()
      hr = HelpfulReview.new
      hr.member_id = current_user.id if current_user
      hr.review_id = review_id
      hr.ipaddress = ip
      hr.save
      insert_id = hr.id

      respond_to do |format|
        format.json { render json:  HelpfulReview.helpful_counts_by_id(review_id).merge({'helpful_id'=>insert_id})}
      end
    else
      respond_to do |format|
        format.json { render json:  {'failed' => 'needs number'} }
      end
    end
  end

  def get_cities
    state = params[:state]
    @cities = City.popular_cities(state) if state.present?

    respond_to do |format|
      format.js
    end
  end

  def get_schools
    state_param = params[:state]
    city = params[:city]
    state = States.abbreviation(state_param) if state_param.present?

    @schools = School.within_city(state,city) if state.present? && city.present?

    respond_to do |format|
      format.js
    end
  end

  def get_school_and_forward
    school_id = params[:school_id]
    state = params[:state]

    school = School.find_by_state_and_id(state,school_id)
    if school.present?
      redirect_to (params[:morganstanley].present? ?  school_review_form_path(school) + "?morganstanley=1" :
          school_review_form_path(school))
    else
      render 'error/school_not_found', layout: 'error', status: 404
    end
  end

end

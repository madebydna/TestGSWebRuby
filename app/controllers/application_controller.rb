class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionManagement

  helper :all

  rescue_from Exception, :with => :exception_handler

  before_filter :login_from_cookie

  helper_method :logged_in?, :current_user

  def require_state
    state = params[:state] || ''
    state.gsub! '-', ' ' if state.length > 2
    state_abbreviation = States.abbreviation(state)

    if state_abbreviation
      params[:state] = state_abbreviation.downcase
    else
      render 'error/school_not_found', layout: 'error', status: 404
    end

    @state = params[:state]
  end

  # Finds school given request param schoolId
  def find_school
    school_id = params[:schoolId].to_i
    state = params[:state]

    if school_id > 0
      School.on_db(state.downcase.to_sym).find school_id
    else
      nil
    end
  end

  def require_school
    @school = find_school

    render 'error/school_not_found', layout: 'error', status: 404 if @school.nil?
  end


  # authorization

  def login_required
    logged_in? && authorized? ? true : access_denied
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        if request.xhr?
          store_location(request.referrer)
          render :js => "window.location='#{signin_path}';", :content_type => 'text/javascript'
        else
          store_location
          redirect_to signin_path
        end
      end
    end
    false
  end


  def exception_handler(e)
    logger.error e

    # consider_all_requests_local is true in Development environment
    # Allows better_errors error messaging for engineers and error_handler logic for other environments
    # unless ?real_error_pages=true set in URL
    if Rails.application.config.consider_all_requests_local && params[:real_error_pages].nil?
      raise e
    end

    # redirect to a not-found or internal error page
    case e
      when ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound
        render 'error/page_not_found', layout: 'error', status: 404
      else
        render 'error/internal_error', layout: 'error', status: 500
    end
  end

end

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all

  rescue_from Exception, :with => :exception_handler

  def require_state
    state = params[:state]

    render 'error/school_not_found', layout: 'error', status: 404 if state.nil? || state.blank?

    state.gsub! '-', ' '
    params[:state] = States.abbreviation(state).downcase
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

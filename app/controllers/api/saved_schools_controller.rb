# frozen_string_literal: true

class Api::SavedSchoolsController < ApplicationController

  def create
    begin
      school_id = params[:school_id]
      state = params[:state]
      user = User.find_by_email(params[:email]) if params[:email]
      user ||= current_user if logged_in?
      school = School.find_by_state_and_id state, school_id
      user.add_favorite_school! school
      render json: {status: 200}  #handle non 200's
    rescue ServerError => e
      GSLogger.error(:misc, e, message:'Error saving school', vars: params)
      render json: {status: 400}
    end
  end

  def destroy
    #confirm: remove from list_msl and add to list_active_history?
  end

end
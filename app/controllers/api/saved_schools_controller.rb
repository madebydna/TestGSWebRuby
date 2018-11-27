# frozen_string_literal: true

class Api::SavedSchoolsController < ApplicationController
  include AuthenticationConcerns
  include SavedSchoolsParams

  before_action :current_user?

  def create
    if fetch_user_saved_schools(current_user).include?([school_state, school_id])
      GSLogger.warn(:misc, e, message:'School already in list', vars: params)
      render json: {status: 501}
    else
      school = School.on_db("#{school_state}").active.find_by!(id: "#{school_id}")
      saved_school = FavoriteSchool.create_saved_school_instance(school, current_user.id)
      if saved_school.save
        render json: {status: 200}
      else
        GSLogger.error(message:'Error adding school', vars: params)
        render json: {status: 400}
      end
    end
  end

  def destroy
    #confirm: remove from list_msl and add to list_active_history?
    if fetch_user_saved_schools(current_user).include?([school_state, school_id])
      saved_school = FavoriteSchool.find_by(state: school_state, school_id: school_id, member_id: current_user.id)
      if saved_school.destroy
        render json: {status: 200}
      else
        GSLogger.error(message:'Error deleting school', vars: params)
        render json: {status: 400}
      end
    else
      GSLogger.warn(message:'School not in list', vars: params)
      render json: {status: 501}
    end
  end

  def current_user?
    render json: {status: 200} unless current_user
  end
end
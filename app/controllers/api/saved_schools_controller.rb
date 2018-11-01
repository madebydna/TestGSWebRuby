# frozen_string_literal: true

class Api::SavedSchoolsController < ApplicationController
  include AuthenticationConcerns
  include SavedSchoolsParams

  def create
    begin
      raise "School Already in List" if fetch_user_saved_schools(current_user).include?([school_state, school_id])
      school = School.on_db("#{school_state}").active.find_by!(id: "#{school_id}")
      saved_school = FavoriteSchool.created_saved_school_instance(school, current_user.id)
      saved_school.save!
      render json: {status: 200}
    rescue => e
      GSLogger.error(:misc, e, message:'Error adding school', vars: params)
      render json: {status: 400}
    end
  end

  def destroy
    #confirm: remove from list_msl and add to list_active_history?
    begin
      raise "School Not in List" unless fetch_user_saved_schools(current_user).include?([school_state, school_id])
      saved_school = FavoriteSchool.where(state: school_state, school_id: school_id, member_id: current_user.id).first!
      saved_school.destroy!
      render json: {status: 200}
    rescue => e
      GSLogger.error(:misc, e, message:'Error deleting school', vars: params)
      render json: {status: 400}
    end
  end

end
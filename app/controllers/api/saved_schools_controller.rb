# frozen_string_literal: true

class Api::SavedSchoolsController < ApplicationController
  include SavedSchoolsParams

  # def create
  #   begin
  #     school_id = params[:school_id]
  #     state = params[:state]
  #     user = User.find_by_email(params[:email]) if params[:email]
  #     user ||= current_user if logged_in?
  #     school = School.find_by_state_and_id state, school_id
  #     user.add_favorite_school! school
  #     render json: {status: 200}  #handle non 200's
  #   rescue ServerError => e
  #     GSLogger.error(:misc, e, message:'Error saving school', vars: params)
  #     render json: {status: 400}
  #   end
  # end

  def create
    begin
      raise "School Already in List" if db_schools.include?([school_state, school_id])
      school = School.on_db("#{school_state}").active.find_by!(id: "#{school_id}")
      saved_school = FavoriteSchool.persist_saved_school(saved_school, current_user.id)
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
      raise "School Not in List" unless db_schools.include?([school_state, school_id])
      saved_school = FavoriteSchool.where(state: school_state, school_id: school_id, member_id: current_user.id).first!
      saved_school.destroy!
      render json: {status: 200}
    rescue => e
      GSLogger.error(:misc, e, message:'Error deleting school', vars: params)
      render json: {status: 400}
    end
  end

  # this endpoint is only trigger at login/initial merging of schools. Will merge 
  # together the schools and persist into the database
  def consistentify_schools
    begin
      saved_schools = (params[:schools] || []).map { |school| [school["state"]&.downcase, school["id"]&.to_i] }
      # only add new schools since this route will only be reached when signed in
      (saved_schools - db_schools).each do |school_params|
        selected_school = School.on_db("#{school_params[0]}").active.find_by!(id: "#{school_params[1]}")
        school_obj = FavoriteSchool.persist_saved_school(selected_school, current_user.id)
        school_obj.save!
      end

      render json: {status: 200}
    rescue => e
      GSLogger.error(:misc, e, message:'Error saving school(s)', vars: params)
      render json: {status: 400}
    end
  end

end
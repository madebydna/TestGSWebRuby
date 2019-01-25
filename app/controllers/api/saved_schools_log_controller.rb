# frozen_string_literal: true

class Api::SavedSchoolsLogController < ApplicationController

  def create
    # uuid is always set by application_controller before this action is evaluated
    uuid = read_cookie_value(:gs_aid)
    add_missing_member_ids(uuid) if current_user
    
    saved_schools_log = FavoriteSchoolLog.new(saved_schools_log_params.merge(member_id: current_user&.id, uuid: uuid))
    if saved_schools_log.save 
      render json: {status: 200}
    else
      GSLogger.warn(message:'Unable to create record in list_msl_log', vars: params)
      render json: {status: 400}
    end
  end

  private

  def saved_schools_log_params
    params.require(:saved_schools_log).permit(:location, :action, :state, :school_id)
  end

  def add_missing_member_ids(uuid)
    FavoriteSchoolLog.where(uuid: uuid).update_all(member_id: current_user.id)
  end

end

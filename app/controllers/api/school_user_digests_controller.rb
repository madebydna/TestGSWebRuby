class Api::SchoolUserDigestsController < ApplicationController

  def show
    if logged_in?
      state = school_user_digest_params[:state]
      school_id = school_user_digest_params[:school_id]
      school = School.find_by_state_and_id(state, school_id)
      @school_user_digest = SchoolUserDigest.new(current_user.id, school).create
    else
      render json: {}, status: :forbidden # :forbidden = 403
    end
  end

  private

  def school_user_digest_params
    params.permit(:state, :school_id)
  end
end

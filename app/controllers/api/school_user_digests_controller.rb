class Api::SchoolUserDigestsController < ApplicationController

  def show
    render json: {}, status: :forbidden unless logged_in? # :forbidden = 403
    state =  school_user_digest_params[:state]
    school_id = school_user_digest_params[:school_id]
    school = School.find_by_state_and_id(state, school_id)
    @school_user_digest = SchoolUserDigest.new(current_user.id, school).create
  end

  private

  def school_user_digest_params
    params.permit(:state, :school_id)
  end
end

class SchoolUserController < SchoolProfileController

  def create
    json_message = {}
    status = :ok
    school_user = nil
    user_type = school_user_params[:user_type]

    begin
      school_user = build_school_user
      school_user.user_type = user_type if user_type
      unless school_user.save
        status = :unprocessable_entity
        Rails.logger.error("Error occurred while attempting to save school_user. school_user.errors: #{school_user.errors.full_messages}")
      end
    rescue Exception => e
      Rails.logger.error("Error occurred while attempting to build school member: #{e}. params: #{params}")
      status = :unprocessable_entity
    end

    respond_to do |format|
      format.json { render json: json_message, status: status }
    end
  end

  def build_school_user
    unless logged_in?
      raise Exception.new('User not logged in')
    end
    unless @school
      raise Exception.new('Current school is unknown')
    end
    SchoolMember.build_unknown_school_member(@school, current_user)
  end

  private

  def school_user_params
    params.
        require(:school_member).
        permit(
        :user_type
          )
  end

end
class SchoolUserController < SchoolProfileController

  def create
    json_message = {}
    status = :ok
    school_user = nil
    user_type = school_user_params[:user_type]

    begin
      school_user = find_or_initialize_school_user
      school_user.user_type = user_type if user_type
      unless school_user.save
        status = :unprocessable_entity
        Rails.logger.error("Error occurred while attempting to save school_user. school_user.errors: #{school_user.errors.full_messages}")
      end
      school_user.handle_saved_reviews_for_students_and_principals
      current_user.send_thank_you_email_for_school(@school)
    rescue Exception => e
      Rails.logger.error("Error occurred while attempting to build school member: #{e}. params: #{params}")
      status = :unprocessable_entity
    end

    respond_to do |format|
      format.json { render json: json_message, status: status }
    end
  end

  def find_or_initialize_school_user
    unless logged_in?
      raise Exception.new('User not logged in')
    end
    unless @school
      raise Exception.new('Current school is unknown')
    end

    school_user = SchoolUser.find_by_school_and_user(@school, current_user)
    school_user ||= SchoolUser.build_unknown_school_user(@school, current_user)
    school_user
  end

  private

  def school_user_params
    params.
        require(:school_user).
        permit(
        :user_type
          )
  end

end
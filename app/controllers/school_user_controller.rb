class SchoolUserController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    @school = school
    errors = []
    status = :ok
    school_user = nil
    user_type = school_user_params[:user_type]

    begin
      school_user = find_or_initialize_school_user
      school_user.user_type = user_type if user_type
      unless school_user.save
        status = :unprocessable_entity
        errors << 'There was a problem saving your relationship to this school'
        Rails.logger.error("Error occurred while attempting to save school_user. school_user.errors: #{school_user.errors.full_messages}")
      end
      school_user.handle_saved_reviews_for_students_and_principals
      current_user.send_thank_you_email_for_school(@school)
    rescue Exception => e
      errors << 'There was a problem saving your relationship to this school'
      Rails.logger.error("Error occurred while attempting to build school member: #{e}. params: #{params}")
      status = :unprocessable_entity
    end

    errors.uniq!

    respond_to do |format|
      format.json { render json: { errors: errors }, status: status }
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

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(get_school_params[:state_abbr], get_school_params[:id])
  end

  def get_school_params
    params.permit(:schoolId, :school_id, :state)
    params[:id] = params[:schoolId] || params[:school_id]
    params[:state_abbr] = States.abbreviation(params[:state].gsub('-', ' '))
    params
  end

  def school_user_params
    params.
        require(:school_user).
        permit(
        :user_type
          )
  end

end

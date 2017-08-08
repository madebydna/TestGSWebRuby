module SchoolParamsConcerns

  protected

  # Finds school given request param schoolId
  def find_school
    school_id = (params[:schoolId] || params[:school_id]).to_i

    if school_id > 0
      School.on_db(state_param.downcase.to_sym).find school_id rescue nil
    else
      nil
    end
  end

  def require_school
    @school = find_school if params[:schoolId].to_i > 0 || params[:school_id].to_i > 0

    @school.extend SchoolProfileDataDecorator

    if @school.blank?
      if city_param
        redirect_to city_path(city_params(state_param, city_param)), status: :found
      else
        redirect_to state_path(state_params(state_param)), status: :found
      end
    elsif !@school.active? && !@school.demo_school?
      redirect_to city_path(city_params(@school.state_name, @school.city)), status: :found
    end
  end


end

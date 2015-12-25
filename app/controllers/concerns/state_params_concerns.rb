module StateParamsConcerns

  protected

  def state_param
    state = (gs_legacy_url_decode(params[:state]) || '').dup
    state_abbreviation = States.abbreviation(state)
    state_abbreviation.downcase! if state_abbreviation.present?
    state_abbreviation
  end

  def state_param_safe
    state_param
  end

  def require_state
    render 'error/page_not_found', layout: 'error', status: 404 if state_param.blank?
  end

  #todo think of better name than require_state_instance_variable or refactor require_state code
  def require_state_instance_variable
    if @state.nil?
      block_given? ? yield : render('error/page_not_found', layout: 'error', status: 404)
    end
  end

  def set_verified_city_state
    if params[:state].present?
      long_name = States.state_name(gs_legacy_url_decode(params[:state])) || return
      short_name = States.abbreviation(gs_legacy_url_decode(params[:state])) || return
      @state = {long: long_name, short: short_name}
    end
    if params[:city]
      city = gs_legacy_url_decode(params[:city])
      city = City.find_by_state_and_name(@state[:short], city) || return
      @city = city
    end
  end

end

# frozen_string_literal: true

module CommunityParams

  def city
    gs_legacy_url_decode(params[:city])&.gs_capitalize_words
  end

  def city_record
    @_city_record ||= City.find_by(name: city, state: States.abbreviation(state), active: 1)
  end

  def county_record
    @_county_record ||= city_record&.county
  end

  def district
    gs_legacy_url_decode(params[:district])
  end

  def district_record
    @_district_record ||= District.on_db(States.abbreviation(state)).find_by(name: district, active: 1)
  end

  def state
    return nil unless params[:state].present?
    state_param = params[:state]

    if States.is_abbreviation?(state_param)
      state_param
    else
      States.abbreviation(state_param.gsub('-', ' ').downcase)
    end
  end

  def state_name
    States.state_name(state)
  end

  def level_code_param
    params[:levelCode] || 'e'
  end

  def set_level_code_params(level_code)
    params[:levelCode] = level_code
  end

  def csa_years
    ensure_array_param(:csaYears)
  end

  def set_csa_winner_param(current_year)
    params[:csaYears] = current_year || []
  end

  def extras
    default_extras + extras_param
  end

  def extras_param
    params[:extras]&.split(',') || []
  end

  def default_extras
    []
  end

  private

  def ensure_array_param(param_name, delim = ',') 
    v = params[param_name] || []
    v.is_a?(Array) ? v : v.split(delim)
  end

end
# frozen_string_literal: true

module CommunityParams

  def city
    params[:city]&.gsub('-', ' ')&.gsub('_', '-')&.gs_capitalize_words
  end

  def city_record
    @_city_record ||= City.find_by(name: city, state: States.abbreviation(state), active: 1)
  end

  def district
    params[:district]
  end

  def district_record
    @_district_record ||= District.on_db(States.abbreviation(state)).find_by(name: district, active: 1)
  end

  def state
    params[:state]
  end

  def level_code
    params[:levelCode]
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

end
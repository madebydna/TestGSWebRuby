# frozen_string_literal: true

module CityParams

  def city_record
    @_city_record ||= City.find_by(name: city, state: States.abbreviation(state), active: 1)
  end

  def city
    params[:city]&.gsub('-', ' ')&.gsub('_', '-')&.gs_capitalize_words
  end

  def state
    params[:state]
  end
end
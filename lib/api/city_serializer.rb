# frozen_string_literal: true

class Api::CitySerializer
  def initialize(city)
    @city = city
  end

  def to_hash
    {
      city: @city.name,
      state: @city.state.upcase,
      lat: @city.lat,
      lon: @city.lon,
    }
  end
end

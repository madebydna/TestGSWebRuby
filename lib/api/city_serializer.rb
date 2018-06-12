# frozen_string_literal: true

class Api::CitySerializer
  def initialize(city)
    @city = city
  end

  def to_hash
    {
      city: @city.name,
      state: @city.state.upcase,
      cityLat: @city.lat,
      cityLon: @city.lon,
    }
  end
end

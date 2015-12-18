module PopularCitiesConcerns

  protected

  def popular_cities
    return @_popular_cities if defined?(@_popular_cities)
    @_popular_cities = (
      City.popular_cities(@state[:short], limit: 28)
    )
  end

end

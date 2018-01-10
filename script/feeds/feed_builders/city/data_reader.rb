module Feeds
  module City
    class DataReader
      include Feeds::FeedConstants
      include Rails.application.routes.url_helpers
      include UrlHelper

      attr_reader :state

      def default_url_options
        { trailing_slash: true, protocol: 'https', host: 'www.greatschools.org', port: nil }
      end

      def initialize(state)
        @state = state
      end

      def each_result(&block)
        cities = ::City.active.where(state: state).order(:name).extend(::City::CollectionMethods).preload_ratings
        hashes = cities.map { |city| format(city) }
        hashes.each(&block)
      end


      private


      def format(city)
        {
          id: city.id,
          name: city.display_name,
          state: city.state,
          rating: city.rating.try(:round),
          url: city_url(city_params(city.state, city.name)),
          lat: city.lat,
          lon: city.lon,
          active: city.active
        }
      end
    end
  end
end

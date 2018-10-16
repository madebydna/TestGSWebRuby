# frozen_string_literal: true

module Search
  class CityDocument
    include Indexable
    include Retrievable

    def initialize(city:)
      @city = city
    end

    def self.from_id(id)
      CityDocument.new(City.find_by_id(id))
    end

    # retrievable

    def self.from_unique_key(key)
      CityDocument.from_id(key)
    end

    # indexable

    def self.type
      'City'
    end

    def unique_key
      self.class.unique_key(@city.id)
    end

    def build
      return {} unless @city
      super
      add_field(:city_name, @city.name, Search::SolrIndexer::Types::TEXT)
      add_field(:state, @city.state.downcase, Search::SolrIndexer::Types::STRING)
      add_field(:number_of_schools, number_of_schools, Search::SolrIndexer::Types::INTEGER)
    end

    # impl

    def self.unique_key(id)
      "#{id}"
    end

    def number_of_schools
      School.on_db(@city.state.downcase.to_sym).where(city: @city.name).active.count
    end
  end
end

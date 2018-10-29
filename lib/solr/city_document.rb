# frozen_string_literal: true

module Solr
  class CityDocument < Document
    include Indexable

    attr_writer :id

    def self.from_active_cities
      City.active.find_each.lazy.flat_map do |city|
        new(city: city)
      end
    end

    def self.from_id(id)
      new(id: id)
    end

    def self.all_fields
      [].tap do |array|
        array << new_field(:city_id, type: FieldTypes::INTEGER) { city.id }
        array << new_field(:city_name, type: FieldTypes::TEXT) { city.name }
        array << new_field(:state, type: FieldTypes::STRING) { city.state.downcase }
        array << new_field(:number_of_schools, type: FieldTypes::INTEGER) { number_of_schools }
      end
    end

    define_field_methods(all_fields)
 
    def initialize(city: nil, id: nil)
      @id = id
      @city = city
    end

    # indexable
    def self.type
      'City'
    end

    def id
      city_id
    end

    def city
      @city ||= (
        raise "Illegal state, need city or ID" unless @id
        City.find_by_id(id)
      )
    end

    def name
      city_name
    end
    
    private

    # indexable
    def unique_key
      id
    end

    def number_of_schools
      @number_of_schools ||= (
        School.on_db(@city.state.downcase.to_sym).where(city: @city.name).active.count
      )
    end
  end
end

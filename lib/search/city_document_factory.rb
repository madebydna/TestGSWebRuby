# frozen_string_literal: true

module Search
  class CityDocumentFactory
    def documents
      City.active.find_each.lazy.flat_map do |city|
        CityDocument.new(city: city)
      end
    end
  end
end

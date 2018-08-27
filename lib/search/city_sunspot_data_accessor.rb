# frozen_string_literal: true

module Search
  class CitySunspotDataAccessor < Sunspot::Adapters::DataAccessor
    def load_all(ids)
      ids
          .lazy
          .map { |id| CityDocument.from_unique_key(id) }
    end
  end
end

# frozen_string_literal: true

module Search
  class SchoolSunspotDataAccessor < Sunspot::Adapters::DataAccessor
    def load_all(ids)
      ids
        .lazy
        .map { |id| SchoolDocument.from_unique_key(id) }
    end
  end
end

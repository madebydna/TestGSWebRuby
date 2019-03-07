# frozen_string_literal: true

module Search
  class NullQuery < SchoolQuery
    include Pagination::Paginatable
    
    def initialize(*args)
      super(*args)
    end

    def response
      OpenStruct.new(
        facet_fields: []
      )
    end

    def search 
      @_search ||= begin
        PageOfResults.new(
          [],
          query: self,
          total: 0,
          offset: 0,
          limit: 1
        )
      end
    end
  end
end
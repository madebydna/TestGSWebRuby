# frozen_string_literal: true

module Search
  class PageOfResults < SimpleDelegator
    include Pagination::Paginatable
    include Pagination::Paginated

    def self.from_paginatable_query(results, query)
      new(
        results,
        query: query,
        total: query.total,
        offset: query.offset,
        limit:  query.limit
      )
    end

    def initialize(results, query:nil, total:, offset:, limit:)
      # by default delegate to results, by way of SimpleDelegator
      super(results) 
      @query = query
      self.total = total
      self.offset = offset
      self.limit = limit
    end

    def pagination_summary
      @query.try(:pagination_summary,self)
    end

    def result_summary
      @query.try(:result_summary,self)
    end
  end
end
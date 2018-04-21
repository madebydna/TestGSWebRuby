# frozen_string_literal: true

module Search
  class Results
    extend Forwardable
    include Enumerable

    def_delegators :@documents, :each, :current_page, :total_pages, :per_page, :first_page?, :last_page?, :prev_page?, :next_page?, :offset, :out_of_bounds

    def initialize(documents, query)
      @documents = documents
      @query = query
    end

    def total
      @documents.total_count
    end

    def index_of_first_result
      offset + 1
    end

    def index_of_last_result
      last_page? ? total : offset + per_page
    end

    def pagination_summary
      @query&.pagination_summary(self)
    end

    def result_summary
      @query&.result_summary(self)
    end
  end
end

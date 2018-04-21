# frozen_string_literal: true

class Api::PaginationSummarySerializer
  def initialize(paginatable_results)
    @paginatable_results = paginatable_results
  end

  def to_hash
    {
      result_summary: @paginatable_results.result_summary,
      pagination_summary: @paginatable_results.pagination_summary
    }
  end
end

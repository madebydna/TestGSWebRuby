# frozen_string_literal: true

class Api::PaginationSummarySerializer
  def initialize(paginatable_results)
    @paginatable_results = paginatable_results
  end

  def to_hash
    {
      resultSummary: @paginatable_results.result_summary,
      paginationSummary: @paginatable_results.pagination_summary
    }
  end
end

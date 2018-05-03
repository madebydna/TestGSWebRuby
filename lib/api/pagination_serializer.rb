# frozen_string_literal: true

class Api::PaginationSerializer

  def initialize(paginatable_results)
    @paginatable_results = paginatable_results
  end

  def to_hash
    {
      total: @paginatable_results.total,
      totalPages: @paginatable_results.total_pages,
      pageSize: @paginatable_results.limit
    }
  end

end

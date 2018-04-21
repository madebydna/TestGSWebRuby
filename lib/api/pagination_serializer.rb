# frozen_string_literal: true

class Api::PaginationSerializer

  def initialize(paginatable_results)
    @paginatable_results = paginatable_results
  end

  def to_hash
    {
      total: @paginatable_results.total,
      current_page: @paginatable_results.current_page,
      offset: @paginatable_results.offset,
      is_first_page: @paginatable_results.first_page?,
      is_last_page: @paginatable_results.last_page?,
      index_of_first_result: @paginatable_results.index_of_first_result,
      index_of_last_result: @paginatable_results.index_of_last_result
    }
  end

end

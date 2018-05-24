# frozen_string_literal: true

module Pagination
  module Paginated
    attr_accessor :total

    # must respond to page
    # must respond to offset
    
    def total_pages
      (total.to_f / limit).ceil
    end

    def previous_page
      page > 1 ? (page - 1) : nil
    end

    def next_page
      page < total_pages ? (page + 1) : nil
    end

    def first_page?
      previous_page.nil?
    end

    def last_page?
      next_page.nil?
    end

    def index_of_first_result
      offset + 1
    end

    def index_of_last_result
      last_page? ? total : offset + limit
    end

    def previous_offset
      [offset - limit, 0].max if offset > 0
    end

    def next_offset
      offset + limit unless last_page?
    end
  end
end

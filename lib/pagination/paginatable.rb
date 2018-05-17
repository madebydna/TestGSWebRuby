# frozen_string_literal: true

module Pagination
  module Paginatable
    attr_writer :page, :offset, :limit, :default_limit, :max_limit
    alias_method :page_size=, :limit=

    def given_page
      @page
    end

    def given_offset
      @offset
    end

    def given_limit
      @limit
    end

    def default_limit
      @default_limit || 10
    end

    def max_limit
      @max_limit || 2000
    end

    def limit
      [given_limit || default_limit, max_limit].min
    end
    alias_method :page_size, :limit

    def page
      if given_page
        given_page
      elsif given_offset
        page_from_offset
      else
        1
      end
    end

    def offset
      if given_offset
        given_offset
      elsif given_page
        offset_from_page
      else
        0
      end
    end

    def page_from_offset
      (given_offset.to_f / limit).ceil + 1
    end

    def offset_from_page
      (given_page - 1) * limit
    end
  end
end

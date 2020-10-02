# frozen_string_literal: true

module Pagination
  module PaginatableRequest
    include Paginatable

    def page_param_name
      :page
    end

    def offset_param_name
      :offset
    end

    def limit_param_name
      :limit
    end

    def given_page
      return nil unless /\d+/.match(params[page_param_name]).to_s == params[page_param_name]
      p = params[page_param_name]&.to_i
      [p, 1].max if p
    end

    def given_offset
      o = params[offset_param_name]&.to_i
      [o, 0].max if o
    end

    def given_limit
      l = params[limit_param_name]&.to_i
      [l, 1].max if l
    end

    def prev_offset_url(paginated)
      unless paginated.first_page?
        url_for(
          request.params.merge(
            offset_param_name => paginated.previous_offset,
            page_param_name => nil
          )
        )
      end
    end

    def prev_page_url(paginated, params_to_remove=nil)
      params_hash = request.params.except!(*params_to_remove)
      unless paginated.first_page?
        url_for(
          params_hash.merge(
            page_param_name => paginated.previous_page,
            offset_param_name => nil
          )
        )
      end
    end

    def next_offset_url(paginated)
      unless paginated.last_page?
        url_for(
          request.params.merge(
            offset_param_name => paginated.next_offset,
            page_param_name => nil
          )
        )
      end
    end

    def next_page_url(paginated, params_to_remove=nil)
      params_hash = request.params.except!(*params_to_remove)
      unless paginated.last_page?
        url_for(
          params_hash.merge(
            page_param_name => paginated.next_page,
            offset_param_name => nil
          )
        )
      end
    end

  end
end

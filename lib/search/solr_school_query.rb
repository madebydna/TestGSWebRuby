# frozen_string_literal: true

module Search
  class SolrSchoolQuery < SchoolQuery
    include Pagination::Paginatable

    def initialize(*args)
      super(*args)
      @client = Sunspot
    end

    def response
      @_response ||= client.search(School, &sunspot_query)
    end

    def search
      @_search ||= begin
        PageOfResults.new(
          School.load_all_from_associates(response.results, &:include_district_name),
          query: self,
          total: response.results.total_count,
          offset: offset,
          limit: limit
        )
      end
    end

    private

    attr_reader :client

    def valid_sort_names
      ['rating', 'name', 'distance']
    end

    def default_sort_name
      'rating'
    end

    def default_sort_direction
      'desc'
    end

    def map_sort_direction(name, _)
      if name == 'distance'
        'asc'
      elsif name == 'name'
        'asc'
      elsif name == 'rating'
        'desc'
      end
    end

    def map_sort_name_to_field(name, _)
      {
        'rating' => 'summary_rating',
        'name' => 'name'
      }[name]
    end

    def q
      if @q.present?
        Solr.require_non_optional_words(@q)
      else
        default_query_string
      end
    end

    def sunspot_query
      lambda do |search|
        # Must reference accessor methods, not instance variables!
        search.keywords(q)
        search.with(:city, city.downcase) if city
        search.with(:state, state.downcase) if state
        # search.with(:latlon).in_radius(32, -68, 100)
        search.with(:level_codes, level_codes.map(&:downcase)) if level_codes.present?
        search.with(:entity_type, entity_types.map(&:downcase)) if entity_types.present?
        search.paginate(page: page, per_page: limit)
        search.order_by(sort_field, sort_direction) if sort_field
        search.adjust_solr_params do |params|
          params[:defType] = browse? ? 'lucene' : 'dismax'   
          params[:qt] = 'school-search' unless browse?
        end
      end
    end
  end
end

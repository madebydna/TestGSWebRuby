# frozen_string_literal: true

Sunspot.config.solr.url = ENV_GLOBAL['solr.ro.server.url']

module Search
  class SolrSchoolQuery < SchoolQuery
    include Pagination::Paginatable

    Sunspot.setup(School) do
      string :city
      string :state
      integer :summary_rating
      latlon(:latlon) { Sunspot::Util::Coordinates.new(lat, lon) }

      # Remove these after we are totally on Solr 7
      string :citykeyword
      string :school_type
      string :school_database_state
      integer :overall_gs_rating
      string :school_grade_level
      integer :overall_gs_rating
      integer :sorted_gs_rating_asc
      integer :school_district_id
      string :school_sortable_name
      float :distance
    end
    Sunspot::Adapters::DataAccessor.register(
      SchoolSunspotDataAccessor,
      School
    )
    Sunspot::Adapters::InstanceAdapter.register(
      SchoolSunspotInstanceAdapter,
      SchoolDocument
    )

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
          School.load_all_from_associates(response.results),
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
      lat && lon ? 'distance' : 'rating'
    end

    def default_sort_direction
      lat && lon ? 'asc' : 'desc'
    end

    def map_sort_direction(name, _)
      if name == 'distance'
        'asc'
      elsif name == 'name'
        'asc'
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

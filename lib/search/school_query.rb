# frozen_string_literal: true

Sunspot.config.solr.url = ENV_GLOBAL['solr.ro.server.url']

module Search
  class SchoolQuery
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
    end
    Sunspot::Adapters::DataAccessor.register(
      SchoolSunspotDataAccessor,
      School
    )
    Sunspot::Adapters::InstanceAdapter.register(
      SchoolSunspotInstanceAdapter,
      SchoolDocument
    )

    attr_accessor :q, :district_id, :city, :level_codes
    attr_reader :state

    def initialize(city:nil, state:nil, q:nil, district_id:nil, level_codes: nil, offset: 0, limit: 25)
      self.city = city
      self.state = state
      self.district_id = district_id
      self.q = q
      self.limit = limit
      self.offset = offset
      self.level_codes = level_codes
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

    def result_summary(results)
      if city
        "#{t('number_of_schools_found', count: results.total)} #{t('in_city_state', city: city, state: state.upcase)}"
      end
    end

    def pagination_summary(results)
      # TODO: requires translation
      total = results.total
      if total == 0
        "Showing 0 schools"
      elsif total == 1
        "Showing 1 school"
      else
        "Showing #{results.index_of_first_result} to #{results.index_of_last_result} of #{results.total} schools"
      end
    end

    # accept state or state abbreviation
    def state=(state)
      return unless state
      abbreviation = States.abbreviation(state)
      unless States.is_abbreviation?(abbreviation)
        raise ArgumentError.new("Not a valid state: #{state}")
      end
      @state = abbreviation
    end

    private

    attr_reader :client

    def t(key, **args)
      I18n.t(key, scope: 'search.number_schools_found', **args)
    end

    def browse?
      state && (city || district_id)
    end

    def default_query_string
      browse? ? '*:*' : 'school'
    end

    def sunspot_query
      lambda do |search|
        # Must reference accessor methods, not instance variables!
        search.keywords(q || default_query_string)
        search.with(:city, city.downcase) if city
        search.with(:state, state.downcase) if state
        # search.with(:latlon).in_radius(32, -68, 100)
        search.paginate(page: page, per_page: limit)
        search.order_by(:summary_rating, :desc)
        search.adjust_solr_params do |params|
          params[:defType] = browse? ? 'lucene' : 'dismax'   
          params[:qt] = 'school-search' unless browse?
        end
      end
    end
  end
end

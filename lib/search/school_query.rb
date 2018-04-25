# frozen_string_literal: true

Sunspot.config.solr.url = ENV_GLOBAL['solr.ro.server.url']

module Search
  class SchoolQuery
    Sunspot.setup(School) do
      string :city
      string :state
      integer :summary_rating
      latlon(:latlon) { Sunspot::Util::Coordinates.new(lat, lon) }

      # Remove these after we are totally on Solr 7
      string :citykeyword
      string :school_database_state
      integer :overall_gs_rating
    end
    Sunspot::Adapters::DataAccessor.register(
      SchoolSunspotDataAccessor,
      School
    )
    Sunspot::Adapters::InstanceAdapter.register(
      SchoolSunspotInstanceAdapter,
      SchoolDocument
    )

    attr_writer :q, :district_id, :city, :page
    attr_reader :q, :district_id, :city, :page, :state

    def initialize(city:nil, state:nil, q:nil, district_id:nil, page:1)
      self.city = city
      self.state = state
      self.district_id = district_id
      self.q = q
      self.page = page
      @client = Sunspot
    end

    def search
      response = client.search(School, &sunspot_query)
      Results.new(response.results, self)
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
        search.paginate(page: page, per_page: 25)
        search.order_by(:summary_rating, :desc)
        search.adjust_solr_params do |params|
          params[:defType] = browse? ? 'lucene' : 'dismax'   
          params[:qt] = 'school-search' unless browse?
        end
      end
    end
  end
end

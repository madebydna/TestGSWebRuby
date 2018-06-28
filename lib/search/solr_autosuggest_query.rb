# frozen_string_literal: true

module Search
  class SolrAutosuggestQuery
    include Rails.application.routes.url_helpers
    include UrlHelper

    attr_accessor :client, :limit
    attr_writer :q

    def initialize(q)
      self.q = q
      @client = Sunspot
      @limit = 250
    end

    def response
      @_response ||= begin
        results = client
          .search(School, &sunspot_query).instance_variable_get(:@solr_result)['response']['docs']
          .map { |r| standardize(r) }
      end
    end

    def q
      @q&.downcase
    end

    def standardize(solr_result)
      city = solr_result['city_sortable_name'] || solr_result['city']
      state = solr_result['state'] || solr_result['city_state']
      state = state.first if state.is_a?(Array)
      district = solr_result['district_sortable_name']
      school_name = solr_result['school_name']
      type = solr_result['document_type']

      url = 
        if type == 'city'
          city_path(
            state: gs_legacy_url_encode(States.state_name(state)),
            city: gs_legacy_url_encode(city),
            trailing_slash: true
          )
        elsif type == 'district'
          district_path(
            state: gs_legacy_url_encode(States.state_name(state)),
            city: gs_legacy_url_encode(city),
            district: gs_legacy_url_encode(district),
            trailing_slash: true
          )
        elsif type == 'school'
          school_path(nil,
            state_name: States.state_name(state),
            city: gs_legacy_url_encode(city),
            id: solr_result['school_id'],
            name: gs_legacy_url_encode(school_name)
          ) + '/'
        end

        {
          city: city,
          state: state.upcase,
          type: type,
          url: url
        }.tap do |hash|
          hash[:school] = school_name if solr_result['document_type'] == 'school'
          hash[:district] = district if solr_result['document_type'] == 'district'
        end
    end

    def search
      @_search ||= begin
        PageOfResults.new(
          response,
          query: self,
          total: response.size,
          offset: 0,
          limit: limit
        )
      end
    end

    def fields
      [
        "contentKey",
        "document_type",
        "school_id",
        "district_id",
        "school_name",
        "city",
        "city_state",
        "state",
        "city_sortable_name",
        "district_sortable_name"
      ]
    end

    def sunspot_query
      lambda do |search|
        # search.keywords(q)
        search.keywords("+(school_name_untokenized:#{q.gsub(' ', '\ ')}* school_name:(#{q}*) city_name:#{q.gsub(' ', '')}*^1.1 district_name:#{q.gsub(' ', '\ ')}*^1.1)")
        search.paginate(page: 1, per_page: limit)
        search.adjust_solr_params do |params|
          params[:fq][0] = nil
          params[:defType] = 'lucene'
          params[:fl] = fields.join(',')
          params[:sort] = 'document_type asc'
        end
      end
    end
  end
end

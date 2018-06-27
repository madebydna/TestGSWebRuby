# frozen_string_literal: true

module Search
  class SolrAutosuggestQuery
    include Rails.application.routes.url_helpers
    include UrlHelper

    attr_accessor :q, :client, :limit

    def initialize(q)
      self.q = q
      @client = Sunspot
      @limit = 100
    end

    def response
      @_response ||= begin
        results = client
          .search(School, &sunspot_query).instance_variable_get(:@solr_result)['response']['docs']
          .map { |r| standardize(r) }
      end
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
          state: state,
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
        search.keywords("+(school_name_untokenized:#{q.gsub(' ', '\ ')}* school_name:(#{q}*) city_name:#{q}*^1.1 district_name:#{q}*^1.1)")
        search.paginate(page: 1, per_page: limit)
        search.adjust_solr_params do |params|
          params[:fq][0] = nil
          params[:defType] = 'lucene'
          params[:fl] = fields.join(',')
          # params[:qf] = 'city_name^99.0 city_name_untokenized^99.0 city_sortable_name^90.0 district_sortable_name^10.0 school_type^3.5 zip^3.0 school_name^2.5 city^0.5 school_district_name^2.5 school_grade_level^1.0 school_database_state^1.0 school_name_synonyms school_subtype'
          # params[:qf] = 'city_keyword city_name city_name_untokenized city_sortable_name'
          params[:qf] = 'city_name^99.0 city_keyword city_name_untokenized^99.0 city_sortable_name^90.0 city_state city_citystate city_citystate_autosuggest city^0.5'
          # params[:qf] = 'city^1.0 city_name^1.0 city_name_untokenized^1.0 city_sortable_name^1.0'
          
        end
      end
    end
  end
end

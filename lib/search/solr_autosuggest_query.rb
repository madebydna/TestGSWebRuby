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

    # ['facet_counts']['facet_fields']['zip']

    def solr_result
      @_solr_result ||= client.search(School, &sunspot_query).instance_variable_get(:@solr_result)
    end

    def response

      rval = solr_result['response']['docs'].map { |r| standardize(r) } + zips
    end

    def zips
      #          zip,   count, zip,   count,
      # returns [94612, 5,     94501, 10,    ...]
      zips_and_counts = solr_result['facet_counts']['facet_fields']['zip']
      zips = zips_and_counts
        .each_slice(2)
        .select { |zip, count| count > 0 }
        .map(&:first) # grab only the zip
        .select do |zip|
          first_numbers = q.match(/^(\d+)/).try(:[],0)
          zip.present? && first_numbers.present? && zip.start_with?(first_numbers)
        end # can have empty string
        .map { |zip| {zip: zip, type: 'zip'}}
    end

    def q
      @q&.downcase.strip
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
          search_city_browse_path(
            state: gs_legacy_url_encode(States.state_name(state)),
            city: gs_legacy_url_encode(city),
            trailing_slash: true
          )
        elsif type == 'district'
          search_district_browse_path(
            state: gs_legacy_url_encode(States.state_name(state)),
            city: gs_legacy_url_encode(city),
            district_name: gs_legacy_url_encode(district),
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
        "district_sortable_name",
        "zip"
      ]
    end

    def q_no_whitespace
      q.gsub(/\s+/, '')
    end

    def q_escape_spaces
      q.gsub(' ', '\ ')
    end

    def query_fragments
      [
        "zip:#{q}*",
        "school_name_untokenized:#{q_escape_spaces}*",
        "school_name:(#{q}*)",
        "city_name:(#{q_no_whitespace} #{q_no_whitespace}*)^5.0",
        "district_name_untokenized:#{q_escape_spaces}*^8.0"
      ]
    end

    def sunspot_query
      lambda do |search|
        # search.keywords(q)
        search.keywords("#{query_fragments.join(' ')}")
        search.paginate(page: 1, per_page: limit)
        search.adjust_solr_params do |params|
          params[:fq][0] = nil
          params[:defType] = 'lucene'
          params[:fl] = fields.join(',')
          params[:facet] = true
          params[:sort] = 'score desc, city_number_of_schools desc, district_number_of_schools desc'
          params['facet.field']='zip'
          # facet=on&facet.field=txt
        end
      end
    end
  end
end

# frozen_string_literal: true

module Search
  class SolrAutosuggestQuery
    include Pagination::Paginatable
    include Rails.application.routes.url_helpers
    include UrlHelper
    include Solr::Query

    attr_accessor :client, :limit
    attr_writer :q

    def initialize(q)
      self.q = q
      @limit = 5
      @searcher = Solr::Searcher.new
    end

    def response
      @_response ||= @searcher.search(self)
    end

    def results
      response.results.map { |r| standardize(r) } + zips
    end

    def zips
      #          zip,   count, zip,   count,
      # returns [94612, 5,     94501, 10,    ...]
      response.facet_counts_for_field('zipcode')
        .each_slice(2)
        .select { |zip, count| count > 0 }
        .map(&:first) # grab only the zip
        .select do |zip|
          zip.present? && possible_zip.present? && zip.start_with?(possible_zip)
        end # can have empty string
        .map { |zip| {value: zip, type: 'zip', url: zipcode_browse_path(zip: zip, sort: 'rating')}}
    end

    def q_downcased
      @q&.downcase&.strip
    end

    def q_no_whitespace
      q_downcased.gsub(/\s+/, '')
    end

    def q_escape_spaces
      q_downcased.gsub(' ', '\ ')
    end

    def extra_solr_params
      {
        'group' => true,
        'group.query' => [
          "document_type:School",
          "document_type:City",
          "document_type:District"
        ],
        'group.limit' => limit
      }
    end

    def query_fragments
      [
        "sortable_name:#{q_escape_spaces}*",
        "name:(#{q_downcased}*)",
        "city_name:(#{require_non_optional_words(q_downcased)}*)^5.0",
        "city_name:(\"#{q_downcased}*\")^5.0",
        "district_name:(#{require_non_optional_words(q_downcased)}*)^8.0",
        "district_name:(\"#{q_downcased}*\")^8.0"
      ].tap do |fragments|
        fragments << "zipcode:#{possible_zip}*" if possible_zip
      end
    end

    # Solr::Query
    def q
      "#{query_fragments.join(' ')}"
    end

    def standardize(solr_result)
      city = solr_result['city'] || solr_result['city_name']
      state = solr_result['state']
      state = state.first if state.is_a?(Array)
      district = solr_result['district_name']
      school_name = solr_result['name']
      type = solr_result['document_type']&.downcase
      school_id = solr_result['id'].split('-')&.last

      url =
        if type == 'city'
          search_city_browse_path(
            state: gs_legacy_url_encode(States.state_name(state)),
            city: gs_legacy_url_encode(city),
            trailing_slash: true
          )
        elsif type == 'district'
          district_path_with_lang(States.state_name(state), city, district)
        elsif type == 'school'
          school_path(nil,
            state_name: States.state_name(state),
            city: gs_legacy_url_encode(city),
            id: school_id,
            name: gs_legacy_url_encode(school_name)
          ) + '/'
        end

        if type == 'school'
          osp_url = osp_registration_path(schoolId: school_id, state: state)
        end

        {
          city: city,
          state: state.upcase,
          type: type,
          url: url
        }.tap do |hash|
          hash[:school] = school_name if type == 'school'
          hash[:district] = district if type == 'district'
          hash[:ospUrl] = osp_url if type == 'school'
        end
    end

    def search
      @_search ||= begin
        PageOfResults.new(
          results,
          query: self,
          total: response.total,
          offset: 0,
          limit: limit
        )
      end
    end

    # Solr::Query
    def field_list
      %w(id
         document_type
         name
         school_district_id
         city
         city_name
         state
         district_name
        )
    end

    def possible_zip
      if defined?(@_possible_zip)
        return @_possible_zip
      end
      # 3 to 5 consecutive numbers surrounded by word boundaries
      @_possible_zip = q_downcased.scan(/\b\d{3,5}\b/).sort_by(&:length).last
    end

    # Solr::Query
    def def_type
      'lucene'
    end

    # Solr::Query
    def facet_fields
      'zipcode' if possible_zip
    end

    # Solr::Query
    def sort
      'score desc, number_of_schools desc'
    end

  end
end

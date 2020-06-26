# frozen_string_literal: true

module Search
  # SchoolQuery is an abstract class that needs all the properties neccessary
  # to be able to find schools by city, lat/lon, etc. But it doesn't specify
  # how we'll retreive the data
  #
  # SolrSchoolQuery is a specific implementation of SchoolQuery. It will use
  # Solr to get data, hence includes the Solr::Query module. Including that
  # module means it will take on the role of a Solr Query in addition to being
  # a SchoolQuery. It needs to implement Solr-specific behavior like
  # document_type, def_type, etc
  class SolrSchoolQuery < SchoolQuery
    include Pagination::Paginatable
    include Solr::Query

    def initialize(*args)
      super(*args)
      @searcher = Solr::Searcher.new
    end

    def response
      @_response ||= @searcher.search(self)
    end

    def search
      @_search ||= begin
        PageOfResults.new(
          response.results.load_external_data!,
          sortable_fields: valid_static_sort_fields + response.populated_facet_fields,
          query: self,
          total: response.total,
          offset: offset,
          limit: limit
        )
      end
    end

    # Solr::Query
    def document_class
      Solr::SchoolDocument
    end

    # Solr::Query
    def extra_solr_params
      return spatial_params(lat, lon, radius, 'latlon') if lat.present? && lon.present?
    end

    # Solr::Query
    def def_type
      browse? ? 'lucene' : 'dismax'
    end

    # Solr::Query
    def query_type
      'school-search' unless browse?
    end

    # Solr::Query
    def filters
      [].tap do |array|
        array << spatial_filter if lat.present? && lon.present?

        if district_id && district_id > 0
          array << eq(:school_district_id, district_id)
        elsif city.present?
          array << eq(:city_untokenized, city.downcase)
          # array << eq(:city, city.downcase)
        end

        if school_keys.present?
          fragment = school_keys.each_with_object([]) do |(state, school_id), phrases|
            phrases << "(+state:#{state} +school_id:#{school_id})"
          end.join(' ')
          array << fragment
        end

        array << eq(:state, state.downcase) if state
        array << self.in(:level_codes, level_codes.map(&:downcase)) if level_codes.present?
        array << self.in(:entity_type, entity_types.map(&:downcase)) if entity_types.present?
        array << self.in(:summary_rating, ratings) if ratings.present?
        array << self.in(:zipcode, zipcode) if zipcode.present?

        test_scores_rating_field = Solr::SchoolDocument.rating_subgroup_field_name('test_scores_rating', rating_subgroup)
        array << self.in(test_scores_rating_field, test_scores_rating) if test_scores_rating.present?
        array << self.in(:csa_badge, csa_years) if csa_years.present?
      end
    end

    # Solr::Query
    def facet_fields
      [
        'test_scores_rating',
        'academic_progress_rating',
        'student_progress_rating',
        'college_readiness_rating',
        'equity_overview_rating',
        'summary_rating',
        'Economically_disadvantaged'
      ] + Omni::Breakdown.unique_ethnicity_names.map do |breakdown|
        "test_scores_rating_#{breakdown.downcase.gsub(' ', '_')}"
      end
    end

    # Solr::Query
    def field_list
      [].tap do |fl|
        fl << '*'
        fl << 'distance:geodist()' if lat.present? && lon.present?
      end
    end

    # Solr::Query
    def q
      if @q.present? && !browse?
        require_non_optional_words(@q)
      else
        default_query_string
      end
    end

    def valid_static_sort_fields
      %w[name rating].tap do |array|
        array << 'relevance' if q.present?
        array << 'distance' if response.results.any?(&:distance) || (lat.present? && lon.present?)
      end
    end

    private

    attr_reader :client

    def default_sort_name
      if @q.present?
        'relevance'
      else
        'rating'
      end
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
        'name' => 'sortable_name',
        'relevance' => 'score',
        'distance' => 'geodist()',
        'testscores' => Solr::SchoolDocument.rating_subgroup_field_name('test_scores_rating', rating_subgroup)
      }[name] || name
    end

    def radius_km
      radius.to_f * M_TO_KM
    end
  end
end

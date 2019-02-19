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
        elsif city
          array << eq(:city, city.downcase)
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
      end
    end

    # Solr::Query
    def facet_fields
      [
        'test_scores_rating',
        'academic_progress_rating',
        'college_readiness_rating',
        'advanced_courses_rating',
        'equity_overview_rating'
      ] + Breakdown.unique_ethnicity_names.map do |breakdown|
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
      if @q.present?
        require_non_optional_words(@q)
      else
        default_query_string
      end
    end

    private

    attr_reader :client

    def valid_static_sort_fields
      %w[name rating].tap do |array|
        array << 'relevance' if q.present?
        array << 'distance' if response.results.any?(&:distance) || (lat.present? && lon.present?)
      end
    end

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
        'distance' => 'geodist()'
      }[name] || name
    end

    def radius_km
      radius.to_f * M_TO_KM
    end

    # def sunspot_query
    #   lambda do |search|
    #     # Must reference accessor methods, not instance variables!
    #     if lat.present? && lon.present?
    #       # I can't get the Sunspot API for geospatial searching to work with sorting by geodist.
    #       # My theory: Sunspot API puts all the parameters inside the geofilt function call. But when sorting by
    #       # geodist, it wants the parameters specified at the top-level. Although passing parameters to the geodist
    #       # function is supported according to the docs, I can't actually get that to work in the sort clause
    #       # search.with(:latlon).in_radius(lat, lon, 5*1.60934)
    #       # search.order_by_geodist(:latlon, lat, lon)
    #       search.adjust_solr_params do |params|
    #         params[:fq] = '{!geofilt}'
    #         params[:sfield] = 'latlon_ll'
    #         params[:pt] = "#{lat},#{lon}"
    #         params[:d] = radius
    #         params[:fl] = '* geodist()'
    #         params[:sort] = 'geodist() asc' unless sort_field
    #       end
    #     else
    #       search.keywords(States.capitalize_any_state_names(q))
    #       if district_id && district_id > 0
    #         search.with(:school_district_id, district_id)
    #       elsif city
    #         search.with(:city, city.downcase)
    #       end
    #       search.adjust_solr_params do |params|
    #         params[:defType] = browse? ? 'lucene' : 'dismax'
    #         params[:qt] = 'school-search' unless browse?
    #       end
    #     end
    #     if school_keys.present?
    #       fragment = school_keys.each_with_object([]) do |(state, school_id), phrases|
    #         phrases << "(+school_database_state:#{state} +school_id:#{school_id})"
    #       end.join(' ')
    #       search.adjust_solr_params do |params|
    #         params[:fq] << fragment
    #       end
    #     end
    #     search.order_by(sort_field, sort_direction) if sort_field
    #     search.with(:state, state.downcase) if state
    #     search.with(:level_codes, level_codes.map(&:downcase)) if level_codes.present?
    #     search.with(:entity_type, entity_types.map(&:downcase)) if entity_types.present?
    #     search.paginate(page: page, per_page: limit)
    #   end
    # end
  end
end

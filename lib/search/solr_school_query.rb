# frozen_string_literal: true

module Search
  class SolrSchoolQuery < SchoolQuery
    include Pagination::Paginatable

    M_TO_KM = 1.60934

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
          preserve_distance_from_solr(
            School.load_all_from_associates(response.results, &:include_district_name)
          ),
          query: self,
          total: response.results.total_count,
          offset: offset,
          limit: limit
        )
      end
    end

    def preserve_distance_from_solr(schools)
      hash = response.instance_variable_get(:@solr_result)['response']['docs'].each_with_object({}) do |doc, h|
        sd = SchoolDocument.from_unique_key(doc['id'].gsub(doc['type']+' ', ''))
        h[[sd.state.upcase, sd.school_id.to_i]] = doc
      end
      schools.map do |s|
        distance = (hash[[s.state, s.id]] || {})['geodist()']
        if distance
          distance /= M_TO_KM
          s.define_singleton_method(:distance) do
            distance
          end
        end
        s
      end
    end

    private

    attr_reader :client

    def default_sort_name
      if @q.present?
        'relevance'
      elsif lat && lon
        nil
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
        'relevance' => 'score'
      }[name] || name
    end

    def q
      if @q.present?
        Solr.require_non_optional_words(@q)
      else
        default_query_string
      end
    end

    def radius_km
      radius.to_f * M_TO_KM
    end

    def sunspot_query
      lambda do |search|
        # Must reference accessor methods, not instance variables!
        if lat.present? && lon.present?
          # I can't get the Sunspot API for geospatial searching to work with sorting by geodist.
          # My theory: Sunspot API puts all the parameters inside the geofilt function call. But when sorting by
          # geodist, it wants the parameters specified at the top-level. Although passing parameters to the geodist
          # function is supported according to the docs, I can't actually get that to work in the sort clause
          # search.with(:latlon).in_radius(lat, lon, 5*1.60934)
          # search.order_by_geodist(:latlon, lat, lon)
          search.adjust_solr_params do |params|
            params[:fq] << '{!geofilt}'
            params[:sfield] = 'latlon_ll'
            params[:pt] = "#{lat},#{lon}"
            params[:d] = radius
            params[:fl] = '* geodist()'
            params[:sort] = 'geodist() asc' unless sort_field
          end
        else
          search.keywords(q)
          if district_id && district_id > 0
            search.with(:school_district_id, district_id)
          elsif city
            search.with(:city, city.downcase)
          end
          search.adjust_solr_params do |params|
            params[:defType] = browse? ? 'lucene' : 'dismax'
            params[:qt] = 'school-search' unless browse?
          end
        end
        if school_keys.present?
          fragment = school_keys.each_with_object([]) do |(state, school_id), phrases|
            phrases << "(+school_database_state:#{state} +school_id:#{school_id})"
          end.join(' ')
          search.adjust_solr_params do |params|
            params[:fq] << fragment
          end
        end
        search.order_by(sort_field, sort_direction) if sort_field
        search.with(:state, state.downcase) if state
        search.with(:level_codes, level_codes.map(&:downcase)) if level_codes.present?
        search.with(:entity_type, entity_types.map(&:downcase)) if entity_types.present?
        search.with(:summary_rating, ratings) if ratings.present?

        search.paginate(page: page, per_page: limit)
      end
    end
  end
end

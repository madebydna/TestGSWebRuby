# frozen_string_literal: true

module Search
  class LegacySolrSchoolQuery < SolrSchoolQuery

    def response
      @_response ||= begin
        client.search(School, &sunspot_query).tap do |res|
          res.instance_variable_get(:@solr_result)['response']['docs'].each do |doc|
            key = SchoolDocument.unique_key(doc['school_database_state'].first, doc['school_id'])
            class_name = 'School'
            doc['id'] = "#{class_name} #{key}"
          end
        end
      end
    end

    def map_sort_name_to_field(name, direction)
      if name == 'distance'
        return 'distance'
      elsif name == 'rating' && direction == 'asc'
        return 'sorted_gs_rating_asc'
      elsif name == 'rating' && direction == 'desc' 
        return 'overall_gs_rating'
      else
        {
          'name' => 'school_sortable_name'
        }[name]
      end
    end

    def sunspot_query
      spatial_query = nil
      if lat && lon
        radius_in_km = radius.to_f * 1.6 # convert to KM
        spatial_query = "{!spatial circles=#{lat},#{lon},#{radius_in_km}}"
      end

      lambda do |search|
        # Must reference accessor methods, not instance variables!
        if lat && lon
          search.keywords(spatial_query)
        else
          search.keywords(q)
        end
        search.with(:citykeyword, city.downcase) if city
        search.with(:school_database_state, state.downcase) if state
        search.with(:school_grade_level, level_codes.map(&:downcase)) if level_codes.present?
        search.with(:school_type, entity_types.map(&:downcase)) if entity_types.present?
        if district_id
          search.with(:school_district_id, district_id) if district_id
        end
        search.paginate(page: page, per_page: limit)
        search.order_by(sort_field, sort_direction) if sort_field
        search.adjust_solr_params do |params|
          params[:defType] = browse? ? 'lucene' : 'dismax'
          params[:qt] = 'school-search' unless browse?
          # the first criteria is type:School, but that field doesn't exist
          # replace it with the way we filter document types
          params[:fq][0] = 'document_type:school'
          params[:fq].map! do |param|
            param.sub(/_s(\W)/, '\1').sub(/_i(\W)/, '\1')
          end
          params[:sort] = params[:sort].sub(/_i(\W)/, '\1') if params[:sort]
          params[:sort] = params[:sort].sub(/_s(\W)/, '\1') if params[:sort]
          params[:sort] = params[:sort].sub(/_f(\W)/, '\1') if params[:sort]
          if district_id == 0
            params[:fq] << '-school_district_id:[1 TO 99999]'
          end
        end
      end
    end
  end
end

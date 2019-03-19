module Solr
  module Query
    M_TO_KM = 1.60934

    attr_accessor :field_list, :filters, :extra_solr_params

    QUERY_TYPE_BOOSTS = {
      'school-search' => {
        qf: 'entity_type^3.5 zipcode^3.0 name^2.5 city^2.5 district_name^2.5 state^1.0 school_name_synonyms',
        pf: 'zipcode^5.0 name^4.5 city^4.5 district_name^4.5 street^2.3'
      }
    }

    def params
      fq = filters.clone
      fq << eq('document_type', document_class.document_type) if document_class
      h = {
        defType: def_type,
        qt: query_type,
        q: q,
        fl: field_list,
        fq: fq,
        start: offset,
        rows: limit,
        facet: facet_fields.present?,
        sort: sort
      }.tap do |params|
        params[:'facet.field'] = facet_fields if facet_fields.present?
      end.merge(query_type_boost_params).merge(extra_solr_params || {})

      adjustments.each_with_object(h) do |block, adjusted_params|
        block.call(adjusted_params)
      end
    end

    def query_type_boost_params
      QUERY_TYPE_BOOSTS[query_type.to_s] || {}
    end

    def document_class
      # No default implemented
    end

    def adjustments
      []
    end

    def query_type
    end

    def sort
      "#{sort_field} #{sort_direction}" if sort_field
    end

    def add_extra_param(k, v)
      @extra_params ||= {}
      @extra_params.merge!(k, v)
    end

    def spatial_filter
      '{!geofilt}'
    end

    def spatial_params(lat, lon, radius, lat_lon_field)
      {
        pt: "#{lat},#{lon}",
        d: radius * M_TO_KM,
        sfield: lat_lon_field
      }
    end

    def eq(field, value)
      "#{field}:\"#{value}\""
    end

    def in(field, values)
      values = Array.wrap(values).map { |v| escape_spaces(v) }
      "#{field}:(#{values.join(' OR ')})"
    end

    private

    def escape_spaces(phrase)
      phrase.to_s.gsub(' ', '\ ')
    end

    def require_non_optional_words(*args)
      ::Solr::Solr.require_non_optional_words(*args)
    end
  end
end
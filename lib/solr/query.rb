module Solr
  module Query
    M_TO_KM = 1.60934

    attr_accessor :field_list, :filters, :extra_solr_params

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
      end.merge(extra_solr_params || {})

      adjustments.each_with_object(h) do |block, adjusted_params|
        block.call(adjusted_params)
      end
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
        d: radius,
        sfield: lat_lon_field
      }
    end

    def eq(field, value)
      "#{field}:#{escape_spaces(value)}"
    end

    def in(field, values)
      values = Array.wrap(values).map { |v| escape_spaces(v) }
      "#{field}:(#{values.join(' OR ')})"
    end

    private

    def escape_spaces(phrase)
      phrase.gsub(' ', '\ ')
    end

    def require_non_optional_words(*args)
      ::Solr::Solr.require_non_optional_words(*args)
    end
  end
end
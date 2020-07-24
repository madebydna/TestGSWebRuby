# frozen_string_literal: true

module Search
  class ActiveRecordSchoolQuery < SchoolQuery
    include Pagination::Paginatable

    def max_limit
      return 10 if criteria.blank?
      super
    end

    def total
      criteria_relation.select('count(*) as count').to_a.first.try(:count) || 0
    end

    def search
      @_search ||= begin
        paginated_relation = 
          criteria_relation
            .order("#{sort_field} #{sort_direction}")
            .offset(offset)
            .limit(limit)
        PageOfResults.from_paginatable_query(paginated_relation, self)
      end
    end

    def response
      OpenStruct.new(facet_fields: [])
    end

    def valid_sort_names
      ['distance', 'name']
    end

    def default_sort_name
      'distance' if area_given?
    end

    def default_sort_direction
      'asc'
    end

    def default_sort_field
      'id'
    end

    private

    def map_sort_name_to_field(name, direction)
      return name
    end

    def criteria
      {
        id: id,
        district_id: district_id,
        type: entity_types.presence,
        city: city
      }.select { |_,v| v }
    end

    def criteria_relation
      @_criteria_relation ||= begin
        relation = School.on_db(state.to_s.downcase.to_sym)
          .include_district_name
          .where(criteria)
          .active

        if area_given?
          relation = relation.
            select("#{School.query_distance_function(lat,lon)} as distance").
            having("distance < #{radius}")
        end

        if level_codes
          where_clause =
            level_codes
              .map { |code| 'school.level_code LIKE ?' }
              .join(' OR ')

           params = level_codes.map { |code| "%#{code}%" }
           relation = relation.where(where_clause, *params)
        end

        relation 
      end
    end

    def point_given?
      lat.present? && lon.present? && radius.blank?
    end

    def area_given?
      lat.present? && lon.present? && radius.present?
    end

    def t(key, **args)
      I18n.t(key, scope: 'search.number_schools_found', **args)
    end

  end
end

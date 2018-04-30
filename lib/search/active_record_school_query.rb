# frozen_string_literal: true

module Search
  class ActiveRecordSchoolQuery
    include Pagination::Paginatable

    attr_reader :state, :id, :district_id, :type, :city, :lat, :lon, :radius, :level_code

    def initialize(state:, id: nil, district_id: nil, type: nil, city: nil, lat: nil, lon: nil, radius: nil, level_code: nil, offset: 0, limit: 0)
      @state = state
      @id = id
      @district_id = district_id
      @type = type
      @city = city
      @level_code = level_code
      @lat = lat
      @lon = lon
      @radius = radius
      @offset = offset
      @limit = limit
    end

    def max_limit
      return 10 if criteria.blank?
      super
    end

    def total
      criteria_relation.count(:id)
    end

    def search
      @_search ||= begin
        paginated_relation = 
          criteria_relation
            .order(sort_field)
            .offset(offset)
            .limit(limit)
        PageOfResults.from_paginatable_query(paginated_relation, self)
      end
    end

    def result_summary(results)
      if city
        "#{t('number_of_schools_found', count: results.total)} #{t('in_city_state', city: city, state: state.upcase)}"
      end
    end

    def pagination_summary(results)
      # TODO: requires translation
      total = results.total
      if total == 0
        "Showing 0 schools"
      elsif total == 1
        "Showing 1 school"
      else
        "Showing #{results.index_of_first_result} to #{results.index_of_last_result} of #{results.total} schools"
      end
    end

    private

    def sort_field
      if area_given?
        :distance
      else
        :id
      end
    end

    def criteria
      {
        id: id,
        district_id: district_id,
        type: type,
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

        if level_code
          relation = relation.where('school.level_code LIKE ?', "%#{level_code}%")
        end

        if type
          relation = relation.where('school.type LIKE ?', "%#{type}%")
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

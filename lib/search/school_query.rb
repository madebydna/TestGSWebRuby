# frozen_string_literal: true

module Search
  class SchoolQuery
    include Pagination::Paginatable
    include Sortable

    attr_accessor :q, :district_id, :city, :level_codes, :entity_types, :id, :lat, :lon, :radius
    attr_reader :state

    def initialize(
      id: nil,
      city: nil,
      state: nil,
      district_id: nil,
      q: nil,
      level_codes: nil,
      entity_types: nil,
      lat: nil,
      lon: nil,
      radius: nil,
      sort_name: nil,
      sort_direction: nil,
      offset: -1,
      limit: 25
    )
      self.id = id
      self.city = city
      self.state = state
      self.district_id = district_id
      self.q = q
      self.level_codes = level_codes
      self.entity_types = entity_types
      self.lat = lat
      self.lon = lon
      self.radius = radius
      self.sort_name = sort_name if self.sort_name_valid?(sort_name)
      self.sort_direction = sort_direction
      self.limit = limit
      self.offset = offset
    end

    def search
      raise NotImplementedError
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

    # accept state or state abbreviation
    def state=(state)
      return unless state
      abbreviation = States.abbreviation(state)
      unless States.is_abbreviation?(abbreviation)
        raise ArgumentError.new("Not a valid state: #{state}")
      end
      @state = abbreviation
    end


    private

    attr_reader :client


    def t(key, **args)
      I18n.t(key, scope: 'search.number_schools_found', **args)
    end

    def browse?
      state && (city || district_id)
    end

    def default_query_string
      browse? ? '*:*' : 'school'
    end
  end
end

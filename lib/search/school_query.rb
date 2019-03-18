# frozen_string_literal: true

module Search
  class SchoolQuery
    include Pagination::Paginatable
    include Sortable
    include Rails.application.routes.url_helpers
    include UrlHelper

    attr_accessor :q, :district_id, :district_name, :location_label, :city, :level_codes, :entity_types, :id, :lat,
                  :lon, :radius, :with_rating, :ratings, :school_keys, :test_scores_rating, :rating_subgroup, :csa_years
    attr_reader :state

    def initialize(
      id: nil,
      city: nil,
      state: nil,
      school_keys: [],
      district_id: nil,
      district_name: nil,
      location_label: nil,
      q: nil,
      level_codes: nil,
      entity_types: nil,
      lat: nil,
      lon: nil,
      radius: nil,
      sort_name: nil,
      sort_direction: nil,
      with_rating: false,
      ratings: [],
      test_scores_rating: nil,
      rating_subgroup: nil,
      offset: 0,
      limit: 25,
      csa_years: []
    )
      self.id = id
      self.city = city
      self.state = state
      self.district_id = district_id
      self.district_name = district_name
      self.location_label = location_label
      self.q = q
      self.level_codes = level_codes
      self.entity_types = entity_types
      self.lat = lat
      self.lon = lon
      self.radius = radius
      self.sort_name = sort_name #if self.sort_name_valid?(sort_name)
      self.sort_direction = sort_direction
      self.limit = limit
      self.offset = offset
      self.with_rating = with_rating
      self.ratings = ratings
      self.school_keys = school_keys
      self.test_scores_rating = test_scores_rating
      self.rating_subgroup = rating_subgroup
      self.csa_years = csa_years
    end

    def search
      raise NotImplementedError
    end

    def state_name
      States.state_name(state)
    end

    def result_summary(results)
      district_url = district_url(district_params(state_name, city,  district_name)) if state && city && district_name
      city_url = city_url(city_params(state&.upcase, city)) if state.present? && city.present?
      params = {
        count: results.total,
        first: results.index_of_first_result,
        last: results.index_of_last_result,
        city: city,
        city_url: city_url,
        state: state&.upcase,
        district: district_name,
        district_url: district_url,
        search_term: @q.presence,
        location: location_label || @q
      }
      if lat && lon && radius
        t('distance', **params)
      elsif district_name
        t('district_browse', **params)
      elsif city
        t('city_browse', **params)
      elsif @q.present?
        t('search_term', **params)
      else
        t('showing_number_of_schools', **params)
      end
    end

    def pagination_summary(results)
      t(
        'showing_number_of_schools_found',
        count: results.total,
        first: results.index_of_first_result,
        last: results.index_of_last_result
      )
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
      browse? ? '*:*' : nil
    end
  end
end

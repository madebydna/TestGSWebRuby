# frozen_string_literal: true

module Search
  class SchoolQuery
    include Pagination::Paginatable
    include Sortable
    include Rails.application.routes.url_helpers
    include UrlHelper

    attr_accessor :q, :district_id, :district_name, :location_label, :city, :level_codes, :entity_types, :id, :lat,
                  :lon, :radius, :ratings, :school_keys, :test_scores_rating, :rating_subgroup, :csa_years
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
      level_codes: [],
      entity_types: nil,
      lat: nil,
      lon: nil,
      radius: nil,
      sort_name: nil,
      sort_direction: nil,
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

    def level_code_long(result_count)
      level_code_options = {
        "p" => "Preschool",
        "e" => "Elementary",
        "m" => "Middle",
        "h" => "High"
      }

      if level_codes.length > 1 && result_count == 1
        return t('school')
      elsif level_codes.empty? || level_codes.length > 1 
        return t('schools')
      elsif result_count == 1
        return t("#{level_code_options[level_codes.first]}.one")
      end

      t("#{level_code_options[level_codes.first]}.other")
    end 

    def result_summary(results)
      district_url = district_path(district_params(state_name, city, district_name).merge({trailing_slash: true})) if state && city && district_name
      city_url = city_path(city_params(state&.upcase, city).merge({trailing_slash: true})) if state.present? && city.present?
      state_url = state_path(state_params(state_name).merge({trailing_slash: true})) if state
      params = {
        count: results.total,
        count_delimited: results.total.to_s(:delimited, delimiter: ','),
        first: results.index_of_first_result,
        last: results.index_of_last_result,
        city: city,
        city_url: city_url,
        state: state&.upcase,
        state_long: state_name&.titleize,
        state_url: state_url,
        district: district_name,
        district_url: district_url,
        search_term: Rails::Html::FullSanitizer.new.sanitize(@q.presence),
        level_code_long: level_code_long(results.total),
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
      elsif state 
        t('state_browse', **params)
      else
        t('showing_number_of_schools', **params)
      end
    end

    def pagination_summary(results)
      t(
        'showing_number_of_schools_found',
        count: results.total,
        count_delimited: results.total.to_s(:delimited, delimiter: ','),
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

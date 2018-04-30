# frozen_string_literal: true

class NewSearchController < ApplicationController
  include Pagination::PaginatableRequest

  layout 'application'
  before_filter :redirect_unless_city_found

  def search
    gon.search = {
      schools: schools.map { |s| Api::SchoolSerializer.new(s).to_hash },
    }.merge(Api::CitySerializer.new(city_object).to_hash)
     .merge(Api::PaginationSummarySerializer.new(paginatable_results).to_hash)
  end

  private

  def redirect_unless_city_found
    redirect_to(state_path(States.state_path(state))) unless city_object
  end

  def schools
    @_schools ||= begin
      SchoolCacheQuery
        .decorate_schools(
          paginatable_results,
          'ratings',
          'characteristics'
        )
    end
  end

  # paginatable school documents
  def paginatable_results
    @_paginatable_results ||= school_search.search
  end

  def school_search
    @_school_search ||= begin
      if params[:solr7]
        Search::SchoolQuery.new(city: city, state: state, q:q, level_codes: level_codes, offset: offset, limit: limit)
      else
        Search::LegacySchoolQuery.new(city: city, state: state, q:q, level_codes: level_codes, offset: offset, limit: limit)
      end
    end
  end

  def city_object
    @_city_object ||= City.get_city_by_name_and_state(city, state).first
  end

  def city
    params[:city].try(:gsub, '-', ' ').gs_capitalize_words
  end

  def state
    return nil unless params[:state].present?
    States.abbreviation(params[:state].gsub('-', ' '))
  end

  def q
    params[:q]
  end

  def level_codes
    params[:level_code]&.split(',')
  end
end

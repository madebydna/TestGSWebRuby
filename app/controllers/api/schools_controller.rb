class Api::SchoolsController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include SearchControllerConcerns

  before_action :require_valid_params

  def show
    hash = serialized_schools.first || {}
    render(json: hash)
  end

  def index
    render json: {
      links: {
        prev: self.prev_offset_url(page_of_results),
        next: self.next_offset_url(page_of_results),
      },
      items: serialized_schools
    }.merge(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
    .merge(Api::PaginationSerializer.new(page_of_results).to_hash)
  end

  def require_valid_params
    unless q || point_given? || area_given?
      return require_state
    end
  end

  def require_state
    render json: { errors: ['State is required'] }, status: 404 if state.blank?
  end

  # extra items returned even if not requested (besides school fields etc)
  # SearchRequestParams
  def default_extras
    %w(summary_rating distance assigned enrollment)
  end

  # extras requiring specific ask, otherwise removed from response
  # SearchRequestParams
  def not_default_extras
    %w(geometry)
  end

end

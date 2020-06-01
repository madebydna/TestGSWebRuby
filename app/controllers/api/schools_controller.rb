class Api::SchoolsController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include SearchControllerConcerns
  include SearchTableConcerns
  include Api::Authorization

  before_action :require_valid_params, :require_authorization

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
      items: serialized_schools,
      tableHeaders: breakdown.present? ? compare_schools_table_headers : nil
    }.merge(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
    .merge(Api::PaginationSerializer.new(page_of_results).to_hash)
  end

  def require_valid_params
    unless q || point_given? || area_given? || school_keys.present? || zipcode.present?
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

  def school_keys
    return saved_school_keys if my_school_list?
  end

end

class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  before_action :require_state, :require_school

  layout false

  def reviews_pagination
    offset = params[:offset] || '0'
    limit = params[:limit] || '10'
    filter_by = params[:filter_by] || nil
    order_by = params[:order_by] || nil

    @school_reviews_pagination = @school.reviews_filter group_type:filter_by, order_results_by:order_by, offset_start: offset.to_i, quantity_to_return: limit.to_i
  end
end
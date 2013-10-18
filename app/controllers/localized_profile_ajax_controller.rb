class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  before_filter :require_state, :require_school

  layout :choose_profile_layout

  def choose_profile_layout
    'blank_container'
  end

  def reviews_pagination
    offset = params[:offset] || '0'
    limit = params[:limit] || '10'
    filter_by = params[:filter_by] || ''
    order_by = params[:order_by] || ''
    @school_reviews_pagination = @school.reviews_filter filter_by, order_by, offset.to_i, limit.to_i
  end

end
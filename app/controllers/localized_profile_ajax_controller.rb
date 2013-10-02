class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  # Find school before executing culture action
  before_filter :find_school

  layout :choose_profile_layout
  def choose_profile_layout
    'blank_container'
  end


  def reviews_pagination
    offset = params[:offset] || '0'
    limit = params[:limit] || '10'
    @school_reviews_pagination = @school.reviews_filter '', '', offset.to_i, limit.to_i
  end

end
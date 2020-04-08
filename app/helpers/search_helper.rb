module SearchHelper

  def search_by_location?
    @by_location
  end

  def search_by_name?
    @by_name
  end

  def filtering_search?
    @filtering_search
  end

end
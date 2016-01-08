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

  def guided_search_path(hub)
    state_url_name = gs_legacy_url_encode(States.state_name(hub.state))
    if hub.city
      "/#{state_url_name}/#{gs_legacy_url_city_district_browse_encode(hub.city)}/guided-search"
    else
      "/#{state_url_name}/guided-search"
    end
  end

end
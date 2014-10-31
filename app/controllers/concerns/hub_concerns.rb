module HubConcerns 
  extend ActiveSupport::Concern

  protected

  def set_hub(school = @school)
    return @hub if @hub
    if @by_name # pull from search results if on by name search
      first_school_result_is_in_hub? # memoizes hub into @hub
    elsif school # pull from school directly if on a school page
      hub_matching_school(school)
    end
    hub_matching_current_url unless @hub # fall back on URL if above fail (e.g. search by location or browse)
    #recently_visited_hub unless @hub # fall back on cookies if above fail
    reset_hub_cookies(@hub) if @hub
    @hub
  end

  def has_guided_search?
    set_hub
    @hub ? @hub.hasGuidedSearch : false
  end

  def hub_configs(collection_id)
    unless collection_id
      set_hub
      collection_id = @hub.collection_id
    end
    return nil unless collection_id
    configs_cache_key = "collection_configs-id:#{collection_id}"
    Rails.cache.fetch(configs_cache_key, expires_in: CollectionConfig.hub_config_cache_time,
        race_condition_ttl: CollectionConfig.hub_config_cache_time) do
      CollectionConfig.where(collection_id: collection_id).to_a
    end
  end

  def hub_show_ads?
    set_hub
    if @hub
      return CollectionConfig.show_ads(hub_configs(@hub.collection_id))
    end
    true
  end

  private

  def first_school_result_is_in_hub?
    if @schools.present?
      first_school = School.on_db(@schools.first.database_state.first).find(@schools.first.id)
      @hub = hub_matching_school(first_school)
      @hub.present?
    end
  end

  def hub_matching_current_url
    @hub ||= (
      if @state
        city_name = if @city
                      @city.respond_to?(:name) ? @city.name : @city
                    elsif city_param
                      city_param
                    else
                      nil
                    end
        HubCityMapping.for_city_and_state city_name, @state[:short]
      end
    )
  end

  def hub_matching_school(school)
    @hub ||= (
      if school && school.collection
        school.collection.hub_city_mapping
      end
    )
  end

  def recently_visited_hub
    @hub ||= (
      hub_city_cookie = read_cookie_value(:hubCity)
      hub_state_cookie = read_cookie_value(:hubState)
      if hub_state_cookie # state is required, city is optional
        HubCityMapping.for_city_and_state(hub_city_cookie, hub_state_cookie)
      end
    )
  end

  def reset_hub_cookies(hub_city_mapping)
    write_cookie :ishubUser, 'y'

    if hub_city_mapping
      [
        [:eduPage, hub_city_mapping.has_edu_page?],
        [:choosePage, hub_city_mapping.has_choose_page?],
        [:eventsPage, hub_city_mapping.has_events_page?],
        [:enrollPage, hub_city_mapping.has_enroll_page?],
        [:hubCity, hub_city_mapping.city],
        [:hubState, hub_city_mapping.state]
      ].each do |tuple|
        delete_cookie(tuple[0])
        write_cookie(tuple[0], tuple[1]) if tuple[1]
      end
    end
  end
end

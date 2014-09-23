module HubConcerns 

  extend ActiveSupport::Concern
  
  private

  def set_up_localized_search_hub_params
    if local_search?
      set_hub(@first_school)
    end
  end

  def local_search?
    if search_by_location? || search_by_name?
      first_school_result_is_in_hub?
    else
      hub_city_state? || hub_state?
    end
  end

  def first_school_result_is_in_hub?
    if @schools.present?
      @first_school = School.on_db(@schools.first.database_state.first).find(@schools.first.id)
      is_hub_school?(@first_school)
    end
  end

  def is_hub_school?(school=@school)
    school && !school.try(:collection).nil?
  end

  def hub_city_state?
    @city && @state && HubCityMapping.where(active: 1, city: @city.name, state: @state[:short]).present?
  end

  def hub_state?
    @state && HubCityMapping.where(active: 1, city: nil, state: @state[:short]).present?
  end

  def set_hub(school = @school)
    @hub = determine_hub(school)
  end

  def determine_hub(school = @school)
    current_hub =   hub_matching_school(school) ||hub_matching_current_url
    if current_hub.present?
      reset_hub_cookies(current_hub)
      return current_hub
    else
      return recently_visited_hub
    end
  end

  def hub_matching_current_url
    if defined?(@hub_matching_current_url)
      @hub_matching_current_url
    else
      @hub_matching_current_url = (
        HubCityMapping.for_city_and_state(city_param, @state[:short]) if state_param
      )
    end
  end

  def hub_matching_school(school)
    if defined?(@hub_matching_school)
      @hub_matching_school
    else
      @hub_matching_school ||= (
        if school && school.collection
          school.collection.hub_city_mapping
        end
      )
    end
  end

  def recently_visited_hub
    if defined?(@recently_visited_hub)
      @recently_visited_hub
    else
      @recently_visited_hub ||= (
        hub_city = read_cookie_value(:hubCity)
        hub_state = read_cookie_value(:hubState)
        if hub_city && hub_state
          HubCityMapping.for_city_and_state(hub_city, hub_state)
        end
      )
    end
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

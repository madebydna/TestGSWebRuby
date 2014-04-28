class TopNav
  include CookieConcerns
  attr_reader :cookies

  def initialize(school, hub_params, cookies)
    @school = school
    @hub_params = { state: sanitize(hub_params.try(:[], :state)), city: sanitize(hub_params.try(:[], :city)) }
    @cookies = cookies
    @city = nil
    @state_short = nil
  end

  def topnav_title
    if is_city_home?
      @city = @hub_params[:city]
      @state_short = States.abbreviation(@hub_params[:state])
    elsif is_state_home?
      @state_short = @hub_params[:state]
    else
      @state_short = read_cookie_value(:hubState)
      @city = read_cookie_value(:hubCity)
    end

    reset_hub_cookies(@city, @state_short)

    if @city
      "#{@city.gs_capitalize_words}, #{@state_short.upcase}"
    elsif @state_short
      States.state_name(@state_short).gs_capitalize_words
    else
      nil
    end
  end

  private

  def sanitize(str)
    (str || '').downcase.gsub(/\-/, ' ')
  end

  def reset_hub_cookies(city, state_short)
    write_cookie :ishubUser, 'y'

    if @school
      mapping = HubCityMapping.where(collection_id: @school.collection.id, active: 1).first
      @city = mapping.city
      @state_short = mapping.state
    else
      mapping = HubCityMapping.where(city: @city, state: States.abbreviation(@state_short).try(:upcase), active: 1).first
    end

    if mapping
      [
        [:eduPage, mapping.has_edu_page?],
        [:choosePage, mapping.has_choose_page?],
        [:eventsPage, mapping.has_events_page?],
        [:enrollPage, mapping.has_enroll_page?],
        [:partnerPage, mapping.has_partner_page?],
        [:hubCity, mapping.city],
        [:hubState, mapping.state]
      ].each do |tuple|
        delete_cookie(tuple[0])
        write_cookie(tuple[0], tuple[1]) if tuple[1]
      end
    end
  end

  def is_city_home?
    @hub_params.present? && @hub_params[:city].present?
  end

  def is_state_home?
    @hub_params.present? && !@hub_params[:city].present? && @hub_params[:state].present?
  end
end

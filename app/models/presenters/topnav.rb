class TopNav
  include CookieConcerns
  attr_reader :cookies

  def initialize(school, hub_params, cookies)
    @school, @hub_params, @cookies = school, hub_params, cookies
  end

  def formatted_title
    format title
  end

  private

  def format(raw_title)
    if !raw_title[:city].nil? && !raw_title[:state_short].nil?
      "#{raw_title[:city].gs_capitalize_words}, #{raw_title[:state_short].upcase}"
    elsif !raw_title[:state_short].nil?
      States.state_name(raw_title[:state_short]).gs_capitalize_words
    else
      nil
    end
  end

  def title
    city = nil
    state_short = nil

    if is_city_hub?
      city = @hub_params[:city].gs_capitalize_words
      state_short = States.abbreviation(@hub_params[:state])
    elsif is_state_hub?
      delete_cookie(:hubCity)
      state_short = @hub_params[:state].gs_capitalize_words
    else
      state_short = read_cookie_value(:hubState)
      city = read_cookie_value(:hubCity)
    end

    if @school
      city = @school.hub_city.gs_capitalize_words
      state_short = States.abbreviation(@school.state)
    end

    write_hub_cookies(city, state_short)

    { city: city, state_short: state_short }
  end

  def write_hub_cookies(city, state_short)
    write_cookie :hubCity, city if city
    write_cookie :hubState, States.abbreviation(state_short).upcase if state_short
    write_cookie :ishubUser, 'y'

    mapping = HubCityMapping.where(city: city, state: States.abbreviation(state_short).try(:upcase), active: 1).first

    if mapping
      write_cookie :eduPage, mapping.has_edu_page?
      write_cookie :choosePage, mapping.has_choose_page?
      write_cookie :eventsPage, mapping.has_events_page?
      write_cookie :enrollPage, mapping.has_enroll_page?
      write_cookie :partnerPage, mapping.has_partner_page?
    end
  end

  def is_city_hub?
    @hub_params.present? && @hub_params[:city]
  end

  def is_state_hub?
    @hub_params.present? && !@hub_params[:city] && @hub_params[:state]
  end
end

class TopNav
  include CookieConcerns
  include UrlHelper
  attr_reader :cookies

  def initialize(school, cookies, hub = nil)
    @school = school
    @cookies = cookies
    @hub = hub
  end

  def hub_state
    if @hub
      @hub.state
    else
      read_cookie_value(:hubState)
    end
  end
  alias_method :state, :hub_state

  def state_name
    States.state_name(hub_state).gs_capitalize_words
  end

  def state_short
    States.abbreviation(hub_state)
  end

  def hub_city
    if @hub
      @hub.city
    else
      read_cookie_value(:hubCity)
    end
  end
  alias_method :city, :hub_city

  def city_name
    hub_city.gs_capitalize_words
  end

  def topnav_title
    if hub_city
      "#{city_name}, #{state_short.upcase}"
    elsif hub_state
      state_name
    else
      nil
    end
  end

  def has_topnav?
    @hub.present? || hub_state.present?
  end

  def url_params
    result = {}
    result[:state] = gs_legacy_url_encode(States.state_name(hub_state)) if hub_state
    result[:city] = gs_legacy_url_encode(hub_city) if hub_city
    result
  end

  private

  def sanitize(str)
    (str || '').downcase.gsub(/\-/, ' ')
  end

end

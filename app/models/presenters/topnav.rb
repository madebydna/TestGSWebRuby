class TopNav
  include CookieConcerns
  include UrlHelper
  attr_reader :cookies

  def state
    @state_short
  end

  def city
    @city
  end

  def initialize(school, hub_params, cookies)
    @school = school
    @hub_params = { state: sanitize(hub_params.try(:[], :state)), city: sanitize(hub_params.try(:[], :city)) }
    @cookies = cookies
    @city = nil
    @state_short = nil
    setup_title
  end

  def topnav_title
    if @city
      "#{@city.gs_capitalize_words}, #{@state_short.upcase}"
    elsif @state_short
      States.state_name(@state_short).gs_capitalize_words
    else
      nil
    end
  end

  def has_topnav?
    !@hub_params[:state].blank? || !read_cookie_value(:hubState).nil? || !@school.try(:collection).nil?
  end

  def url_params
    result = {}
    result[:state] = gs_legacy_url_encode(States.state_name @state_short) if @state_short
    result[:city] = gs_legacy_url_encode(@city) if @city
    result
  end

  private

  def setup_title
    if is_hub_school?
      @state_short = @hub_params[:state]
      @city = @hub_params[:city]
    elsif is_city_home?
      @city = @hub_params[:city]
      @state_short = States.abbreviation(@hub_params[:state])
    elsif is_state_home?
      @state_short = @hub_params[:state]
    else
      @state_short = read_cookie_value(:hubState)
      @city = read_cookie_value(:hubCity)
    end

    reset_hub_cookies
  end

  def sanitize(str)
    (str || '').downcase.gsub(/\-/, ' ')
  end

  def reset_hub_cookies
    write_cookie :ishubUser, 'y'

    if @school.try(:collection)
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

  def is_hub_school?
    @school && !@school.try(:collection).nil?
  end
end
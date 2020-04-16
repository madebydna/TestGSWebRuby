# frozen_string_literal: true

module SearchRequestParams
  include UrlHelper

  def state_param_name
    :state
  end

  # Raw user-provided state
  def state_param
    params[state_param_name]
  end

  # State that you can use when making URLs
  def url_state
    gs_legacy_url_encode(States.state_name(state))
  end

  # State abbreviation from user-provided state param
  def state
    state_param = params[:state]
    return nil unless state_param.present?

    if States.is_abbreviation?(state_param)
      state_param
    else
      States.abbreviation(state_param.gsub('-', ' ').downcase)
    end
  end

  # lowercase state name from user-provided state param
  def state_name
    States.state_name(state)
  end

  def is_browse_url?
    request.path.match? /\/schools/
  end

  def q
    params[:q] || params[:query]
  end

  def level_codes
    params = parse_array_query_string(request.query_string)
    codes = params[grade_level_param_name] || params['level_code'] || []
    codes = codes.split(',') unless codes.is_a?(Array)
    codes & ['e', 'm', 'h', 'p']
  end

  def level_code
    level_codes&.first
  end

  def entity_types
    params = parse_array_query_string(request.query_string)
    types = params['st'] || params['type'] || []
    types = types.split(',') unless types.is_a?(Array)
    types & ['public', 'private', 'charter']
  end

  def entity_type
    entity_types.first
  end

  def lat
    params[:lat]&.to_f
  end

  def lon
    params[:lon]&.to_f
  end

  def default_radius
    5
  end

  def radius
    r = radius_param || 5
    if max_radius
      [max_radius, r].min
    else
      r
    end
  end

  def max_radius
    radius_param || default_radius
  end

  def radius_param
    params[:distance]&.to_i || params[:radius]&.to_i
  end

  def location_given?
    point_given? || area_given?
  end

  def point_given?
    lat.present? && lon.present? && radius_param.blank?
  end

  def area_given?
    lat.present? && lon.present? && radius_param.present?
  end

  def boundary_level
    if params[:boundary_level].present?
      params[:boundary_level].split(',') | %w(o)
    elsif level_codes.present?
      levels = level_codes.reject { |l| l == 'p' }.map do |level|
        level == 'e' ? 'p' : level
      end
      (levels & %w(o p m h)) | %w(o)
    else
      %w(o p m h)
    end
  end

  def sort_name
    params[:sort]
  end

  def city_param_name
    :city
  end

  # raw user-provided city param (with hyphens and underscores)
  def city_param
    params[city_param_name]
  end

  # lowercase city name from user-provided param
  def city
    params[city_param_name]&.gsub('-', ' ')&.gsub('_', '-')&.gs_capitalize_words
  end

  # city that you can use when making URLs
  def url_city
    city_param
  end

  def city_record
    return nil unless city
    return @_city_record if defined? @_city_record
    @_city_object = City.get_city_by_name_and_state(city, state)
  end


  def district_param_name
    :district_name
  end

  # raw user-provided district (with hyphens and underscores)
  def district_param
    params[:district] || params[district_param_name]
  end

  # lowercase district name from user-provided district param
  def district
    district_param&.gsub('-', ' ')&.gsub('_', '-')&.gs_capitalize_words
  end

  # district name you can use when making URLs
  def url_district
    district_param
  end

  def district_record
    return nil unless state && (district_id || district)

    @_district_record ||= begin
      if district_id
        DistrictRecord.by_state(state.to_s).where(district_id: district_id).first
      elsif district
        DistrictRecord.by_state(state.to_s).where(name: district).first
      end
    end
  end

  def district_id
    params[:districtId]&.to_i || params[:district_id]&.to_i
  end

  def county_object
    if defined?(@_county_object)
      return @_county_object
    end
    @_county_object = city_record&.county
  end

  def location_label_param
    params[:locationLabel] || params[:locationSearchString]
  end

  def location_label
    location_label_param.gsub(', USA', '')
  end

  def school_id
    params[:id]&.to_i || params[:schoolId]&.to_i
  end

  def district_browse?
    state && district
  end

  def view
    params['view']
  end

  def tableView
    params['tableView']
  end

  def city_browse?
    state.present? && city.present? && district.blank?
  end

  def state_browse?
    state.present? && city.blank? && district.blank? && !zip_code_search?
  end

  def zip_code_search?
    params[:locationType]&.downcase == 'zip'
  end

  def zip_code
    # Stopgap until we pass the zip explicitly
    params[:locationLabel].match(/[0-9]+/)
  end

  def search_type
    if district_browse?
      :district_browse
    elsif city_browse?
      :city_browse
    elsif zip_code_search?
      :zip_code
    elsif street_address?
      :address
    elsif state_browse?
      :state_browse
    else
      :other
    end
  end

  # reading about API design, I tend to agree that rather than make multiple
  # endpoints for different views on the same resource (school) we should allow
  # the client to say what data they want back. Felt like boundary data
  # belongs as part of the schools api resource, but it has performance
  # overhead to obtain that data and not every request needs it. Rather
  # than have the client provide every field desires, just made an "extras"
  # for asking for data not in the default response
  def extras
    default_extras + extras_param
  end

  def extras_param
    params[:extras]&.split(',') || []
  end

  def view_param_name
    'view'
  end

  def table_view_param_name
    'tableView'
  end

  def view
    params['view']
  end

  def tableView
    params['tableView']
  end

  def grade_level_param_name
    'gradeLevels'
  end

  def view_param_name
    'view'
  end

  def table_view_param_name
    'tableView'
  end

  def page_param_name
    'page'
  end

  def school_type_param_name
    'st'
  end

  # to be overridden by controller
  def default_extras
    []
  end

  def street_address?
    params['locationType'] == 'street_address'
  end

  def cast_to_boolean(str)
    {
      'true' => true,
      'false' => false
    }[str]
  end

  #myschoollist params

  def merge_school_keys
    (FavoriteSchool.saved_school_list(current_user.id) + cookies_school_keys).uniq
  end

  def cookies_school_keys
    # If a user saves a school and then removes it, the cookie will be set as '[]'. Code below will return [] in that case.
    cookies[:gs_saved_schools] ? JSON.parse(cookies[:gs_saved_schools]).map {|hash| [hash['state']&.downcase, hash['id']&.to_i]} : []
  end

  def saved_school_keys
    current_user ? merge_school_keys : cookies_school_keys
  end

  def school_keys
    params[:schoolKeys] || []
  end

  def school_list
    params[:schoolList]
  end

  def my_school_list?
    school_list == 'msl'
  end

  def ratings
    params[:overall_gs_rating] || []
  end

  def default_view
    'list'
  end

  def msl_states
    saved_school_keys.map {|school_key| school_key[0]}.uniq.sort
  end

  def state_select
    params[:stateSelect] || msl_states[0]
  end

  def filtered_school_keys
    # schools_keys used here so that this solr parameter will only fire off
    # from MSL controller or from the MSL API call. In other instances, this params
    # is nil/undefined
    school_keys.present? ? saved_school_keys.select {|school_key| school_key[0] == state_select} : nil
  end

  #CompareSchools params
  def breakdown
    params[:breakdown]
  end

  def ethnicity
    pinned_school_ethnicity_breakdowns.include?(breakdown) ? breakdown : pinned_school_ethnicity_breakdowns.sort.first
  end

  def base_school_for_compare
    @_base_school_for_compare ||= begin
      pinned_school = School.on_db(state).find(school_id)
      pinned_school = send("add_summary_rating", pinned_school) if respond_to?("add_summary_rating", true)
      pinned_school = send("add_enrollment", pinned_school) if respond_to?("add_enrollment", true)
      SchoolCacheQuery.decorate_schools([pinned_school], *cache_keys).first
    rescue
      nil
    end
  end

  def pinned_school_ethnicity_breakdowns
    @breakdowns ||= begin
      base_school_for_compare&.ethnicity_breakdowns || []
    end
  end

  def csa_years
    ensure_array_param(:csaYears)
  end

  def csa_year_param
    params[:csaYears] || csa_available_years.first
  end

  private

  def ensure_array_param(param_name, delim = ',')
    v = params[param_name] || []
    v.is_a?(Array) ? v : v.split(delim)
  end

end
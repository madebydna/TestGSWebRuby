# frozen_string_literal: true

module SearchRequestParams
  include UrlHelper

  def state
    state_param = params[:state]
    return nil unless state_param.present?

    if States.is_abbreviation?(state_param)
      state_param
    else
      States.abbreviation(state_param.gsub('-', ' ').downcase)
    end
  end

  def state_name
    States.state_name(state)
  end

  def is_browse_url?
    request.path.match? /\/schools/
  end

  def state_param
    params[:state]
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

  def radius
    radius_param || 5
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

  def city
    params[:city]&.gsub('-', ' ')&.gsub('_', '-')&.gs_capitalize_words
  end

  def county_object
    if defined?(@_county_object)
      return @_county_object 
    end
    @_county_object = city_record&.county
  end

  def city_param
    params[:city]
  end

  def district_param
    params[:district] || params[:district_name]
  end

  def location_label_param 
    params[:locationLabel] || params[:locationSearchString]
  end

  def location_label
    location_label_param.gsub(', USA', '')
  end

  def city_record
    return nil unless city
    return @_city_record if defined? @_city_record
    @_city_object = City.get_city_by_name_and_state(city, state).first
  end

  def school_id
    params[:id]&.to_i
  end

  def district_id
    params[:districtId]&.to_i || params[:district_id]&.to_i
  end

  def district
    district_param&.gsub('-', ' ')&.gsub('_', '-')&.gs_capitalize_words
  end

  def district_record
    return nil unless state && (district_id || district)
    
    @_district_record ||= begin
      if district_id
        District.on_db(state).where(id: district_id).first
      elsif district
        District.on_db(state).where(name: district).first
      end
    end
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
    state && city && !district
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

  def grade_level_param_name
    'gradeLevels'
  end

  def list_table_view_param_name
    'view'
  end

  def which_table_view_param_name
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

  def with_rating
    params[:with_rating]
  end

end
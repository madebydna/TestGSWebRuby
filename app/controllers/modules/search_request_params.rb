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
    codes = params['gradeLevels'] || params['level_code'] || []
    codes = codes.split(',') unless codes.is_a?(Array)
    codes
  end

  def level_code
    level_codes&.first
  end

  def entity_types
    params = parse_array_query_string(request.query_string)
    types = params['st'] || params['type'] || []
    types = types.split(',') unless types.is_a?(Array)
    types
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
    (params[:boundary_level] || '').split(',').tap do |array|
      array << 'o' unless array.include?('o')
    end
  end

  def sort_name
    params[:sort]
  end

  def city
    params[:city]&.gsub('-', ' ')&.gs_capitalize_words
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
    district_param&.gsub('-', ' ')&.gs_capitalize_words
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

  def city_browse?
    state && city
  end

  def zip_code_search?
    /^\d{5}+$/.match?(q)
  end

  def search_type
    if district_browse?
      :district_browse
    elsif city_browse?
      :city_browse
    elsif zip_code_search?
      :zip_code
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

  # to be overridden by controller
  def default_extras
    []
  end

end
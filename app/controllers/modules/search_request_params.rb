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

  def state_param
    params[:state]
  end

  def q
    params[:q]
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
    params[:distance]&.to_i || params[:radius]&.to_i
  end

  def point_given?
    lat.present? && lon.present? && radius.blank?
  end

  def area_given?
    lat.present? && lon.present? && radius.present?
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

  def city_param
    params[:city]
  end

  def city_record
    return nil unless city
    return @_city_object if defined? @_city_object
    @_city_object = City.get_city_by_name_and_state(city, state).first
  end

  def school_id
    params[:id]&.to_i
  end

  def district_id
    params[:districtId]&.to_i || params[:district_id]&.to_i
  end

  def district
    params[:district_name]&.gsub('-', ' ')&.gs_capitalize_words
  end

  def district_record
    return nil unless state && (district_id || district)
    
    @_district_object ||= begin
      if district_id
        District.on_db(state).where(id: district_id).first
      elsif district
        District.on_db(state).where(name: district).first
      end
    end
  end

end
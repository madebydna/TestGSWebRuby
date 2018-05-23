# frozen_string_literal: true

module SearchRequestParams

  def state
    state_param = params[:state]
    return nil unless state_param.present?

    if States.is_abbreviation?(state_param)
      state_param
    else
      States.abbreviation(state_param.gsub('-', ' ').downcase)
    end
  end

  def q
    params[:q]
  end

  def level_codes
    if params[:gradeLevels].present? && params[:gradeLevels].is_a?(Array)
      params[:gradeLevels]
    else
      params[:level_code]&.split(',')
    end
  end
  def level_code
    level_codes&.first
  end

  def entity_types
    if params[:st].present? && params[:st].is_a?(Array)
      params[:st]
    elsif params[:type].present? && params[:type].is_a?(Array)
      params[:type]
    else
      params[:type]&.split(',')
    end
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

  def city_object
    return nil unless city
    @_city_object ||= City.get_city_by_name_and_state(city, state).first
  end

  def district_id
    params[:districtId] || params[:district_id]
  end

  def district
    params[:district]&.gsub('-', ' ')&.gs_capitalize_words
  end

  def district_object
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
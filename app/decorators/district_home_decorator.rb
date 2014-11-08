class DistrictHomeDecorator < Draper::Decorator
  include GradeLevelConcerns

  decorates :district
  delegate_all

  def name
    district.name
  end

  def rating
    '?'
  end

  def number_of_schools_in_district
    real_count = School.on_db(district.state.downcase.to_sym).
      where(district_id: district.id, active: true).
      count
  end

  alias_method :grade_range, :process_level

  def city_state_zip
    if city.present? && zipcode.present?
      "#{city}, #{state} #{zipcode}"
    end
  end

  def district_home_link(text = name)
    district_params = h.district_params_from_district(district)
    url = h.city_district_url(district_params)
    if url.present?
      h.link_to(text, url)
    end
  end

  def city_state
    if city.present?
      "#{city}, #{state}"
    end
  end

  def website_link
    url = district.home_page_url
    if url.present?
      h.link_to('District website', url)
    end
  end

  def boilerplate
    (
      district.boilerplate_object || 
      district.state_level_boilerplate_object
    ).try(:boilerplate)
  end

  def school_browse_url(query_param_hash = nil)
    district_params = h.district_params_from_district(district)
    district_params[:district_name] = district_params[:district]
    district_params.delete(:district)
    district_params.merge!(query_param_hash) if query_param_hash.present?
    
    url = h.search_district_browse_url(district_params)
  end

  def school_browse_link(level_code = nil, &blk)
    level_code_to_label_map = {
      p: 'Preschools',
      e: 'Elementary schools',
      m: 'Middle schools',
      h: 'High schools'
    }
    
    district_params = {}
    district_params[:levelCodes] = level_code if level_code.present?

    url = school_browse_url(district_params)

    if block_given?
      h.link_to(url, &blk)
    else
      h.link_to(
        level_code_to_label_map[level_code.to_sym],
        url
      )
    end
  end
end
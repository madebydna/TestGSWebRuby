class SchoolProfileDecorator < Draper::Decorator
  decorates :school
  delegate_all

  include GradeLevelConcerns
  include SchoolPhotoConcerns

  def link_to_overview(*args, &blk)
    h.link_to h.school_path(school), *args, &blk
  end

  def type
    school.type.gs_capitalize_first
  end

  def full_address
    "#{street} #{city}, #{state} #{zipcode}"
  end

  def full_address_markup
    truncate_length = 45
    "<span itemprop=\"address\" itemscope=\"\" itemtype=\"http://schema.org/PostalAddress\">" \
        "<span itemprop=\"streetAddress\" content=\"#{street}\">#{street.truncate(truncate_length)}</span> " \
        "<span itemprop=\"addressLocality\" content=\"#{city}\">#{city}</span>, " \
        "<span itemprop=\"addressRegion\">#{state}</span> " \
        "<span itemprop=\"postalCode\">#{zipcode}</span></span>".html_safe
  end

  def city_state
    [city, state].join(', ')
  end

  def great_schools_rating
    school_metadata[:overallRating].presence
  end

  def school_type_url
    if school.type == 'public' && school.district.present?
      district_params = h.district_params_from_district(school.district)
      district_params[:district_name] = district_params[:district]
      district_params.delete(:district)
      url = h.search_district_browse_url(district_params)
    else
      city_params = h.city_params(school.state, school.city)
      city_params.merge!('st' =>school.type)
      url = h.search_city_browse_url(city_params)
    end
  end

  def google_formatted_street_address
    address = "#{street},#{city},#{state}+#{zipcode}"
    # We may want to look into CGI.escape() to prevent the chained gsubs
    address.gsub(/\s+/,'+').gsub(/'/,'')
  end

  # DEPRECATED -- please use StructuredMarkup
  def state_breadcrumb_text
    text =
      if state == 'DC'
        'District of Columbia'
      else
        States.state_name(state).gs_capitalize_words
      end
  end

  # DEPRECATED -- please use StructuredMarkup
  def city_breadcrumb_text
    text =
      if state == 'DC'
        'Washington, D.C.'
      else
        city
      end

    text.gs_capitalize_words
  end

  # Returns the url for a location search with the school address at the center of the search
  def school_zip_location_search_url
    # TODO: I just refactored this for OM-1283 and don't think we need the sortBy param but am not 100% sure
    normalizedAddress = school.zipcode
    query_params = {
      lat: school.lat,
      lon: school.lon,
      state: school.state,
      locationType: 'street_address',
      normalizedAddress: normalizedAddress,
      sortBy: 'DISTANCE',
      locationSearchString: normalizedAddress,
      distance: 5,
      sort: 'distance_asc'
    }
    h.search_path(query_params)
  end

# location search for school address, filtered by school level(s) & sorted by rating
  def school_level_and_address_location_search_sorted_by_rating_url
    query_params = {
      lat: school.lat,
      lon: school.lon,
      state: school.state,
      locationType: 'street_address',
      normalizedAddress:  full_address,
      locationSearchString: full_address,
      distance: 3,
      sort:'rating_desc',
      gradeLevels: level_code_array
    }
    h.search_path(query_params)
  end

  def school_boundary_hash
    boundary_hash = { level: single_level_code, schoolId: id, state: state }
    boundary_hash.merge(districtId: district) if district.present?
    boundary_hash
  end

  def single_level_code
    level_value = 'h'
    level_value = 'm' if level_code_array.include? 'm'
    level_value = 'e' if level_code_array.include? 'e'
    level_value = 'p' if level_code_array.include? 'p'
    level_value
  end

 def facebook_url
   cache_results.values_for(EspKeys::FACEBOOK_URL).first || metadata.facebook_url
 end

  def get_all_students_data(hash)
    hash.each do |student_data|
      # require 'pry'
      # binding.pry
      # if student_data['breakdown'].to_s == 'All students'
      #   return student_data
      # end
    end
  end
end

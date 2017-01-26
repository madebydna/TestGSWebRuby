module SchoolHelper

  def draw_stars_16(on_star_count)
    draw_stars 16, on_star_count
  end

  def draw_stars_24(on_star_count)
    draw_stars 24, on_star_count
  end

  def draw_stars_48(on_star_count)
    draw_stars 48, on_star_count
  end

  def zillow_url(school, campaign=nil)
    campaign ||= (zillow_tracking_hash[action_name].present? ? zillow_tracking_hash[action_name] : 'gstrackingpagefail')
    tracking_codes = "?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=#{campaign}"
    # test that values needed are populated
    if school.present? && school.zipcode.present?
      url = "https://www.zillow.com/#{States.abbreviation(school.state).upcase}-#{school.zipcode.split("-")[0]}"
    else
      url = 'https://www.zillow.com/'
    end
    "#{url}#{tracking_codes}"
  end

  # this is the single place to reference naming for school type
  def school_type_display(type)
    school_types_map = {
        charter: 'Public charter',
        public: 'Public district',
        private: 'Private'
    }
    school_types_map[type.to_s.downcase.to_sym]
  end

  #####################################################################################################################
  #
  #   supporting functions only used in this helper
  #
  #####################################################################################################################

  def zillow_tracking_hash
    hash = {
        'overview' => 'localoverview',
        'reviews' => 'localreviews',
        'quality' => 'localquality',
        'details' => 'localdetails',
        'city_browse' => 'schoolsearch',
        'district_browse' => 'schoolsearch',
        'search' => 'schoolsearch',
        'show' => 'schoolsearch',
        'map' => 'widget_map'
    }

  end

  def draw_stars(size, on_star_count)
    off_star_count = 5 - on_star_count
    class_on = "iconx#{size}-stars i-#{size}-orange-star i-#{size}-star-#{on_star_count}"
    class_off = "iconx#{size}-stars i-#{size}-grey-star i-#{size}-star-#{off_star_count}"
    content_tag(:span, '', :class => class_on) + content_tag(:span, '', :class => class_off)
  end

end
module SchoolProfiles
  class Neighborhood
    include ActionView::Helpers::AssetUrlHelper

    MAX_CHARS_LENGTH = 37
    MIN_LONG_ADDRESS_CHAR_COUNT = 22

    MAP_SIZES = {
      "sm" => [767, 450],
      "md" => [991, 450],
      "lg" => [1264, 450]
    }.freeze
    attr_reader :school, :school_rating

    def initialize(school, school_cache_data_reader)
      @school = school
      @school_rating = school_cache_data_reader.gs_rating
    end

    def school_city_state_zip
      zipcode = school.zipcode.to_s[0..4]
      "#{school.city}, #{school.state} #{zipcode}"
    end

    def max_chars
      MAX_CHARS_LENGTH
    end

    def school_address_css_class
      css_class = ""
      css_class = " small-text" if long_address?
      css_class
    end

    def long_address?
      street_char_length = school.street.length
      school_city_state_char_length = school_city_state_zip.length
      street_char_length > MIN_LONG_ADDRESS_CHAR_COUNT ||
        school_city_state_char_length > MIN_LONG_ADDRESS_CHAR_COUNT
    end

    def google_maps_url
      GoogleSignedImages.google_maps_url(
        GoogleSignedImages.google_formatted_street_address(school)
      )
    end

    def static_google_maps
      @_static_google_maps ||= begin
        google_apis_path = GoogleSignedImages::STATIC_MAP_URL
        address = GoogleSignedImages.google_formatted_street_address(school)
        MAP_SIZES.each_with_object({}) do |(label, size), sized_maps|
          sized_maps[label] = GoogleSignedImages.sign_url(
            "#{google_apis_path}?size=#{size[0]}x#{size[1]}&center=#{address}&markers=#{google_maps_icon_param}#{address}&sensor=false"
          )
        end
      end
    end

    private

    def google_maps_icon_param
      if school_rating_valid?
        map_pin_url = image_url(
          "icons/google_map_pins/map_icon_#{school_rating}.png"
        )
        icon_param = "icon:#{map_pin_url}|"
      else
        icon_param = ""
      end
      icon_param
    end

    def school_rating_valid?
      #   the google_maps_icon_param function is not working because image_url helper
      #   does not provide proper path to icon. Ticket filed for fix but forcing
      #   the icon_param to be empty string
      school_rating && (1..10).cover?(school_rating.to_i)
      false
    end
  end
end

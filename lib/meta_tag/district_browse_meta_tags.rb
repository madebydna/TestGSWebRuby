# frozen_string_literal: true

module MetaTag
  class DistrictBrowseMetaTags < MetaTag::MetaTags
    def title
      "#{entity_type_long}#{level_code_long}#{schools_or_preschools} in #{district_record.name}#{title_pagination_text} - #{city_record.name}, #{city_record.state}"
    end

    def description
      "Ratings and parent reviews for all elementary, middle and high schools in the #{district_record.name}, #{city_record.state}"
    end

    def canonical_url
      search_district_browse_url(
        params_for_canonical.merge(
          district_param_name => url_district,
          city_param_name => url_city,
          state_param_name => url_state
        )
      )
    end
  end
end

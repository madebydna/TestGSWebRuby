# frozen_string_literal: true

module MetaTag
  class CityBrowseMetaTags < MetaTag::MetaTags
    def title
      city_type_level_code_text = "#{city_record.name} #{entity_type_long}#{level_code_long}#{schools_or_preschools}"
      "#{city_type_level_code_text}#{title_pagination_text} - #{city_record.name}, #{city_record.state}"
    end

    def description
      if %w(il pa).include?(state)
        "#{city_record.name}, #{city_record.state} school districts, public, private and charter school listings" \
              " and rankings for #{city_record.name}, #{city_record.state}. Find your school district information from Greatschools.org"
      else
        "View and map all #{city_record.name}, #{city_record.state} schools. Plus, compare or save schools"
      end
    end

    def canonical_url
      url_for(
        search_city_browse_url(
          params_for_canonical.merge(
            city_param_name => url_city,
            state_param_name => url_state
          )
        )
      )
    end

    def robots
      serialized_schools.length < 3 ? 'noindex' : nil
    end
  end
end

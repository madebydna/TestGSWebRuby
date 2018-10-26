# frozen_string_literal: true

module Search
  class MetaTags < SimpleDelegator
    include UrlHelper

    def initialize(search_controller)
      super(search_controller)
    end

    def self.from_controller(search_controller)
      self.choose_implementation(search_controller)
        .new(search_controller)
    end

    def self.choose_implementation(search_controller)
      if search_controller.district_browse?
        DistrictBrowseMetaTags
      elsif search_controller.city_browse?
        CityBrowseMetaTags
      elsif search_controller.zip_code_search?
        ZipMetaTags
      elsif search_controller.street_address?
        AddressMetaTags
      else
        OtherMetaTags
      end
    end

    def meta_tag_hash
      {
        robots: robots,
        title: "#{title} | GreatSchools",
        description: description,
        canonical: canonical_url,
        prev: prev_url,
        next: next_url,
        alternate: alternate_url,
      }.gs_remove_empty_values
    end

    private

    def alternate_url
      {
        en: url_for(params_for_canonical.merge(lang: nil)),
        es: url_for(params_for_canonical.merge(lang: :es))
      }
    end

    def robots
      'noindex, nofollow' unless is_browse_url? && any_results?
    end

    def prev_url
      param_to_remove = view == default_view ? view_param_name : nil
      prev_page_url(page_of_results, param_to_remove)
    end

    def next_url
      param_to_remove = view == default_view ? view_param_name : nil
      next_page_url(page_of_results, param_to_remove)
    end

    def canonical_url
      raise NotImplementedError.new("#{self.class.name}#description must be implemented even if it should return nil")
    end

    def description
      raise NotImplementedError.new("#{self.class.name}#description must be implemented even if it should return nil")
    end

    def params_for_canonical
      {}.tap do |key|
        key[grade_level_param_name] = level_codes if level_code.present?
        key[page_param_name] = given_page if given_page.present?
        key[school_type_param_name] = entity_types if entity_types.present?
        key[view_param_name] = view if view.present? && view != default_view
        key[table_view_param_name] = tableView if tableView.present?
      end.compact
    end

    def title_pagination_text
      ", #{page_of_results.index_of_first_result}-#{page_of_results.index_of_last_result}"
    end

    def entity_type_long
      {
        'charter' => 'Public Charter ',
        'public' => 'Public ',
        'private' => 'Private '
      }[entity_type]
    end
  
    def level_code_long
      {
        'e' => 'Elementary ',
        'm' => 'Middle ',
        'h' => 'High ',
        'p' => nil
      }[level_code]
    end
  
    def schools_or_preschools
      school_preschool_map = Hash.new('Schools').merge('p' => 'Preschools')
      school_preschool_map[level_code]
    end
  end


  class DistrictBrowseMetaTags < MetaTags
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


  class CityBrowseMetaTags < MetaTags
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
  end


  class ZipMetaTags < MetaTags
    def title
      "#{entity_type_long}#{level_code_long}#{schools_or_preschools} near #{location_label}#{title_pagination_text} - #{state.upcase}"
    end

    def description
      "Ratings and parent reviews for all elementary, middle and high schools in #{zip_code}, #{state.upcase}"
    end

    def canonical_url
      nil
    end
  end


  class AddressMetaTags < MetaTags
    def title
      "#{entity_type_long}#{level_code_long}#{schools_or_preschools} near #{location_label}"
    end

    def description
      nil
    end

    def canonical_url
      nil
    end
  end


  class OtherMetaTags < MetaTags
    def title
      "#{entity_type_long}#{level_code_long}#{schools_or_preschools} matching #{q}"
    end

    def description
      nil
    end

    def canonical_url
      nil
    end
  end
end
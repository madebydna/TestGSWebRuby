# frozen_string_literal: true

module MetaTag
  class StateBrowseMetaTags < MetaTag::MetaTags
    def title
      state_type_level_code_text = "#{level_code_long}#{schools_or_preschools}"
      "Find the best public, charter #{state_type_level_code_text.downcase} in #{States.state_name(state).titleize}#{title_pagination_text}"
    end

    def description
      state_type_level_code_text = "#{level_code_long}#{schools_or_preschools}"
      "View & compare ratings, parent reviews, & information about #{page_of_results.total} public, charter #{state_type_level_code_text.downcase} in #{States.state_name(state).titleize}."
    end

    def canonical_url
      url_for(
        search_state_browse_url(
          params_for_canonical.merge(
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

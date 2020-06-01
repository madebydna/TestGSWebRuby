# frozen_string_literal: true

module MetaTag
  class ZipMetaTags < MetaTag::MetaTags
    def title
      "#{entity_type_long}#{level_code_long}#{schools_or_preschools} in #{zipcode}#{title_pagination_text}"
    end

    def description
      "Ratings and parent reviews for all elementary, middle and high schools in #{zipcode}."
    end

    def canonical_url
      nil
    end
  end
end
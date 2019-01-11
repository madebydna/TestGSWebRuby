# frozen_string_literal: true

module MetaTag
  class ZipMetaTags < MetaTag::MetaTags
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
end
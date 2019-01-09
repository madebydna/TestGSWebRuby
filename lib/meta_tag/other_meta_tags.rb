# frozen_string_literal: true

module MetaTag
  class OtherMetaTags < MetaTag::MetaTags
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
# frozen_string_literal: true

module MetaTag
  class AddressMetaTags < MetaTag::MetaTags
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
end
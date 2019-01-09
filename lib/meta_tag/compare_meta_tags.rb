# frozen_string_literal: true

module MetaTag
  class CompareMetaTags < MetaTag::MetaTags
    def title
      "Compare #{base_school_for_compare&.name} to nearby schools - #{base_school_for_compare&.city}, #{state_name&.gs_capitalize_words} - #{state.upcase} | GreatSchools"
    end

    def description
      "View schools near #{base_school_for_compare&.name}. Compare school ratings, test scores and more."
    end

    def canonical_url
      nil
    end

    def prev_url
      nil
    end

    def next_url
      nil
    end

    def og
      {
        title: "Compare #{base_school_for_compare&.name} to nearby schools in #{base_school_for_compare&.city}, #{state.upcase}",
        description: "We're an independent nonprofit that provides parents with in-depth school quality information.",
        site_name: 'GreatSchools.org',
        image: {
          url: asset_full_url('assets/share/logo-ollie-large.png'),
          secure_url: asset_full_url('assets/share/logo-ollie-large.png'),
          height: 600,
          width: 1200,
          type: 'image/png',
          alt: 'GreatSchools is a non profit organization providing school quality information'
        },
        type: 'place',
        url: request.original_url
      }
    end

    def twitter
      {
        image: asset_full_url('assets/share/GreatSchoolsLogo-social-optimized.png'),
        card: 'Summary',
        site: '@GreatSchools',
        description: "We're an independent nonprofit that provides parents with in-depth school quality information."
      }
    end

    def robots
      nil
    end

    def alternate_url
      nil
    end
  end
end
# frozen_string_literal: true

module MetaTag
  class CollegeSuccessAwardsMetaTags < MetaTag::MetaTags
    include UrlHelper
    
    def title
      t('title', scope: 'lib.college_success_award', year: csa_year_param, state: States.capitalize_any_state_names(States.abbreviation_hash[state]) )
    end

    def description
      "The GreatSchools College Success Award recognizes the top high schools in #{States.capitalize_any_state_names(States.abbreviation_hash[state])} doing the best job preparing students to enroll & succeed in college"
    end

    def canonical_url
      "#{state_college_success_awards_list_url(States.abbreviation_hash[state])}"
    end

    def og
      {
        title: t("facebook_title", scope:'lib.college_success_award.og', state: States.capitalize_any_state_names(States.abbreviation_hash[state]), year: csa_year_param ),
        description: t("facebook_post_copy", scope:'lib.college_success_award.og'),
        site_name: 'GreatSchools.org',
        image: {
          url: asset_full_url('assets/share/CSA-social.png'),
          secure_url: asset_full_url('assets/share/CSA-social.png'),
          height: 600,
          width: 1200,
          type: 'image/png',
          alt: '2019 GreatSchools College Success Award Winners'
        },
        type: 'website',
        url: add_query_params_to_url(request.original_url, false, utm_source: "College Success Awards", utm_medium: "Facebook" )
      }
    end

    def twitter
      {
        title: t("facebook_title", scope:'lib.college_success_award.og', state: States.capitalize_any_state_names(States.abbreviation_hash[state]), year: csa_year_param),
        image: asset_full_url('assets/share/CSA-social-twitter.png'),
        card: 'Summary',
        site: '@GreatSchools',
        description: "Top schools in the state that excel in preparing students for college success."
      }
    end

    def robots
      nil
    end
  end
end

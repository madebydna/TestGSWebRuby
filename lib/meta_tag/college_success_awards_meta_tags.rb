# frozen_string_literal: true

module MetaTag
  class CollegeSuccessAwardsMetaTags < MetaTag::MetaTags
    def title
      t('title', scope: 'lib.college_success_award', year: csa_year_param, state: States.capitalize_any_state_names(States.abbreviation_hash[state]) )
    end

    def description
      "The GreatSchools College Success Award recognizes the top high schools in #{States.capitalize_any_state_names(States.abbreviation_hash[state])} doing the best job preparing students to enroll & succeed in college"
    end

    def canonical_url
      "#{state_url(state_params(state))}college-success-award/"
    end

    def robots
      nil
    end
  end
end

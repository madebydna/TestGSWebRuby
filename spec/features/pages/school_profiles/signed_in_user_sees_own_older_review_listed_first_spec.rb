require "spec_helper"
require 'features/contexts/shared_contexts_for_signed_in_users'
require "features/page_objects/school_profiles_page"

describe "Signed in and verified user" do
  with_shared_context 'signed in verified user' do
    after do
      clean_dbs(:gs_schooldb)
      clean_models(:ca, School)
    end

    scenario "user's older review listed above more recent reviews", js: true do
      page_object = SchoolProfilesPage.new
      school = create(:school_with_new_profile, id: 1)
      newer_reviews = create_list(:five_star_review, 4, school: school)

      user_old_comment = "User overall comment for an old review that should be on top"
      old_review_from_user = create(:five_star_review,
                                    user: user,
                                    comment: user_old_comment,
                                    created: Date.parse('2012-01-01'),
                                    school: school
                                   )

      visit school_path(school)
      within review_list do
        expect(page).to have_css ".five-star-review .comment", text: user_old_comment
        expect(page).to have_css ".user-reviews-container .date", text: "January 01, 2012"
      end
    end
  end
  def review_list
    ".review-list"
  end
end

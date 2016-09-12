require "spec_helper"
require "features/page_objects/school_profiles_page"

describe "Visitor" do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario "sees an overall review from community member" do
    review_comment = "Smple riw cmnt with engh chars & wrds to be valid h s f s"
    school = create(:school_with_new_profile, id: 1)
    user = create(:verified_user, id: 1)
    community_member = create(:community_school_user,
                              member_id: user.id,
                              school_id: school.id,
                              state: school.state
                             )
    review_created_time = Time.parse("2016-09-09 07:00:00 -0700")
    five_star_review_with_comment = create(:five_star_review,
                                           answer_value: 5,
                                           active: 1,
                                           comment: review_comment,
                                           created: review_created_time,
                                           user: user,
                                           state: school.state,
                                           school_id: school.id,
                                           id: 1)


    visit school_path(school)
    within review_list do
      expect(page).to have_css ".review__header", text: "Overall experience"
      expect(page).to have_css ".review__user-type", text: "community member"
      expect(page).to have_css ".review__text", text: review_comment
      expect(page).to have_css ".review__date", text: "September 09, 2016"
    end
  end

  def review_list
    ".review-list"
  end
end

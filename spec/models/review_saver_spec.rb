require "spec_helper"

describe ReviewSaver do
  after do
    clean_dbs(:ca, :gs_schooldb)
  end
  context "with no existing review" do
    context "with valid review" do
      it 'should save a valid review' do
        verified_user = create(:verified_user)
        school = create(:alameda_high_school, id: 1)
        school_user = create_school_user(verified_user, school)
        review = build(:review, user: verified_user, school_id: school.id)

        expect{ReviewSaver.new(review, school_user).save}
          .to change{Review.count}.from(0).to(1)
      end

      it "should return saved review true and saved review" do
        verified_user = create(:verified_user)
        school = create(:alameda_high_school, id: 1)
        school_user = create_school_user(verified_user, school)
        review = build(:review, user: verified_user, school_id: school.id)

        expect(ReviewSaver.new(review, school_user).save).to eq([true, review])
      end
    end
    context "with invalid review" do
      it "should not save review" do
        verified_user = create(:verified_user)
        school = create(:alameda_high_school, id: 1)
        school_user = create_school_user(verified_user, school)
        invalid_comment = "test"
        review = build(:review, user: verified_user, comment: invalid_comment)

        expect{ReviewSaver.new(review, school_user).save}
          .not_to change{Review.count}
      end
      it "should return false and an unsaved review with correct error messages" do
        verified_user = create(:verified_user)
        school = create(:alameda_high_school, id: 1)
        school_user = create_school_user(verified_user, school)
        invalid_comment = "test"
        review = build(:review, user: verified_user, comment: invalid_comment)

        review_save_boolean, unsaved_review = ReviewSaver.new(review, school_user).save
        expect(review_save_boolean).to eq(false)
        expect(unsaved_review).to eq(review)
        expect(unsaved_review.errors.full_messages)
          .to eq(["comment is too short (minimum is 7 words)"])
      end
    end
  end

  context "with existing review" do
    context "with valid review" do
      it "should save review" do
        verified_user = create(:verified_user)
        school = create(:alameda_high_school, id: 1)
        school_user = create_school_user(verified_user, school)
        existing_review = create(:homework_review, user: verified_user)
        review = build(:homework_review, user: verified_user)

        expect{ReviewSaver.new(review, school_user).save}
          .to change{Review.count}.from(1).to(2)
      end

      it "should deactivate older review" do
        verified_user = create(:verified_user)
        school = create(:alameda_high_school, id: 1)
        school_user = create_school_user(verified_user, school)
        existing_review = create(:homework_review,
                                 school_id: school.id,
                                 user: verified_user,
                                 review_question_id: 2,
                                )

        new_review = build(:homework_review,
                       school_id: school.id,
                       user: verified_user,
                       review_question_id: 2,
                      )

        expect{ReviewSaver.new(new_review, school_user).save}
          .to change{Review.count}.from(1).to(2)
        expect(Review.first).to eq(existing_review)
        expect(Review.last).to eq(new_review)
        expect(Review.first.active).to eq(false)
        expect(Review.last.active).to eq(true)
        expect(Review.active.count).to eq(1)
        expect(Review.count).to eq(2)
      end
    end
  end

    def create_school_user(user, school)
      school_user = create(:community_school_user, user: user, school: school)
      school_user
    end
  end


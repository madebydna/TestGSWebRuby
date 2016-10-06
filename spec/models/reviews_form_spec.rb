require "spec_helper"

describe ReviewsForm do
  after do
    clean_dbs(:ca, :gs_schooldb)
  end

  it "should be ActiveModel-compliant" do
    reviews_form = build_reviews_form
    expect(reviews_form).to be_a(ActiveModel::Model)
  end

  it "validates presence of state" do
    reviews_form = build_reviews_form(state: '')

    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:state]).to eq(["Must provide school state"])
  end

  it "validates presence of school id" do
    reviews_form = build_reviews_form(school_id: '')

    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:school_id]).to eq(["Must provide school id"])
  end

  it "validates presence of school in database" do
    reviews_form = build_reviews_form

    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:school]).to eq(["Specified school was not found"])
  end

  it "validates the validity of the reviews submitted for school" do
    school = create(:alameda_high_school, id: 1)
    invalid_comment = "test this"

    reviews_params = build_reviews_params(comment: invalid_comment)

    error_messages_result = [{1=> {comment: ["comment is too short (minimum is 15 words"]}}]
    reviews_form = build_reviews_form(reviews_params: reviews_params)
    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:reviews]).to eq(error_messages_result)
  end

  describe "#save" do
    context "with valid params" do
      it "saves reviews in database" do
        school = create(:alameda_high_school, id: 1)
        comment = ("test this " * 15).strip
        reviews_params = build_reviews_params

        reviews_form = build_reviews_form(reviews_params: reviews_params)
        expect{reviews_form.save}.to change{Review.count}.by(1)
      end

      context "with old reviews to deactivate" do
        context "with successful deactivation of old reviews" do
          it "should save new review" do
            comment = ("test this " * 15).strip
            school = create(:alameda_high_school, id: 1)
            verified_user = create(:verified_user)
            existing_review = create(:teacher_effectiveness_review, user: verified_user, school_id: 1)
            reviews_params = build_reviews_params(review_question_id: "2")
            reviews_form = build_reviews_form(reviews_params: reviews_params, user: verified_user)
  
            expect(reviews_form.valid?).to eq(true)
            expect{reviews_form.save}.to change{Review.count}.by(1)
          end
          it "should deactivate old review" do
            comment = ("test this " * 15).strip
            school = create(:alameda_high_school, id: 1)
            verified_user = create(:verified_user)
            existing_review = create(:teacher_effectiveness_review, user: verified_user, school_id: 1, review_question_id: 2)
            reviews_params = build_reviews_params(review_question_id: "2")
            reviews_form = build_reviews_form(reviews_params: reviews_params, user: verified_user)

            expect(reviews_form.valid?).to eq(true)
            expect{reviews_form.save}.not_to change{Review.active.count}
            expect(Review.active.first.comment).to eq(comment)
            expect(Review.inactive.first).to eq(existing_review)
          end
        end

        context "with unsuccessful deactivation of reviews" do
          it "should return errors for reviews not deactivated" do

          end
        end

        context "with one invalid saving of a review" do
          it "should return false" do
            school = create(:alameda_high_school, id: 1)
            verified_user = create(:verified_user)
            review = build(:teacher_effectiveness_review, user: verified_user, school_id: 1)
            reviews_params = build_reviews_params
            allow_any_instance_of(ReviewSaver).to receive(:save).and_return([false, review])
            reviews_form = build_reviews_form(reviews_params: reviews_params)
            
            expect(reviews_form.save).to eq(false)
          end
        end
      end
    end

    context "with invalid params" do
      it "does not save reviews in database" do
        school = create(:alameda_high_school, id: 1)
        invalid_comment = "test this "
        reviews_params = build_reviews_params(comment: invalid_comment)
        reviews_form = build_reviews_form(reviews_params: reviews_params)

        expect{reviews_form.save}.not_to change{Review.count}
      end
    end
  end

  describe "#reviews" do
    context "with review answer params" do
      it "should return reviews" do
        comment = ("test this " * 15).strip
        reviews_params = build_reviews_params + build_reviews_params(review_question_id: "2")
        reviews_form = build_reviews_form(reviews_params: reviews_params)

        expect(reviews_form.reviews.all? { |r| r.is_a?(Review)}).to be(true)
        expect(reviews_form.reviews.all? { |r| r.answers.first.is_a?(ReviewAnswer)}).
          to eq(true)
      end
    end
  end

  describe '#review_params' do
    it "should return review and answer params" do
      reviews_form = build_reviews_form
      comment = ("test this " * 15).strip

      review_params = {
        "review_question_id"=>"1",
        "comment"=> comment,
        "answer_value"=>"5",
      }

      review_params_result = {
        "review_question_id"=>"1",
        "comment"=> comment
      }

      answer_params_result = {"answer_value" => "5"}
      review, answer = reviews_form.review_params(review_params)
      expect(review).to eq(review_params_result)
      expect(answer).to eq(answer_params_result)
    end
  end

  describe "#hash_result" do
    context "with no errors in saved questions" do
      it "should return reviews hash without errors" do
        school = create(:alameda_high_school, id: 1)
        verified_user = create(:verified_user)
        saved_review = create(:teacher_effectiveness_review, user: verified_user, school_id: 1)
        reviews_form = build_reviews_form
        valid_reviews = [saved_review]
        allow(reviews_form).to receive(:saved_reviews).and_return(valid_reviews)
        hash_result = {
          "#{saved_review.topic.id}" => {
            comment: saved_review.comment,
            answer: saved_review.answer,
          }
        }

        expect(reviews_form.hash_result).to eq(hash_result)
      end
    end
    context "with one review with error" do
      it "should return reviews hash with one question with error" do
        school = create(:alameda_high_school, id: 1)
        verified_user = create(:verified_user)
        invalid_comment = "comment"
        saved_review = build(:teacher_effectiveness_review, comment: invalid_comment, user: verified_user, school_id: 1)
        saved_review.valid?
        reviews_form = build_reviews_form
        invalid_reviews = [saved_review]
        allow(reviews_form).to receive(:saved_reviews).and_return(invalid_reviews)
        review_question_id = saved_review.review_question_id
        hash_result = {
          "#{saved_review.topic.id}" => {
            comment: saved_review.comment,
            answer: saved_review.answer,
            errors: ["comment is too short (minimum is 15 words)"]
          }
        }

        expect(reviews_form.hash_result).to eq(hash_result)
      end
    end
  end

  def build_reviews_form(state: 'CA',
                         school_id: '1',
                         user: create(:verified_user),
                         reviews_params: [])
    params = {
      state: state,
      school_id: school_id,
      reviews_params: reviews_params.to_json,
      user: user
    }
    ReviewsForm.new(params)
  end

  def build_reviews_params(review_question_id: "1",
                           comment: ("test this " * 15).strip,
                           answer_value: "5"
                          )
    [{
      "review_question_id"=>review_question_id,
      "comment"=> comment,
      "answer_value"=>answer_value,
    }]
  end
end

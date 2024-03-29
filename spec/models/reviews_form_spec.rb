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
    reviews_form = build_reviews_form(state: "")

    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:state]).to eq(["Must provide school state"])
  end

  it "validates presence of school id" do
    reviews_form = build_reviews_form(school_id: "")

    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:school_id]).to eq(["Must provide school id"])
  end

  it "validates presence of school in database" do
    reviews_form = build_reviews_form

    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:school]).to eq(["Specified school was not found"])
  end

  it "validates the validity of the reviews submitted for school" do
    create(:alameda_high_school, id: 1)
    create(:review_question, id: 1)
    invalid_comment = "test this"

    reviews_params = build_reviews_params(comment: invalid_comment)

    error_messages_result = [{1=> "comment is too short (minimum is 7 words)"}]
    reviews_form = build_reviews_form(reviews_params: reviews_params)
    expect(reviews_form).to be_invalid
    expect(reviews_form.errors[:reviews]).to eq(error_messages_result)
  end

  it 'validates presence of review question' do
    create(:alameda_high_school, id: 1)
    reviews_params = build_reviews_params(review_question_id: 0)
    reviews_form = build_reviews_form(reviews_params: reviews_params)
    expect(reviews_form).to be_invalid
  end

  describe "#save" do
    context "with valid params" do
      it "saves reviews in database" do
        create(:alameda_high_school, id: 1)
        create(:review_question, id: 1)

        reviews_params = build_reviews_params
        reviews_form = build_reviews_form(reviews_params: reviews_params)
        expect{reviews_form.save}.to change{Review.count}.by(1)
      end

      context "with old reviews to deactivate" do
        context "with successful deactivation of old reviews" do
          before do
            create(:alameda_high_school, id: 1)
            @verified_user = create(:verified_user)
            @existing_review = create(:teacher_effectiveness_review, user: @verified_user, school_id: 1)
          end

          it 'should save new review' do
            create(:review_question, id: 15)
            @existing_review.review_question_id = 15
            @existing_review.save!

            reviews_params = build_reviews_params(review_question_id: '15')
            reviews_form = build_reviews_form(reviews_params: reviews_params, user: @verified_user)

            expect(reviews_form.valid?).to eq(true)
            expect{reviews_form.save}.to change{Review.count}.by(1)
          end

          it 'should deactivate old review' do
            comment = ('new comment ' * 15).strip

            create(:review_question, id: 15)
            @existing_review.review_question_id = 15
            @existing_review.save!
            reviews_params = build_reviews_params(comment: comment, review_question_id: '15')
            reviews_form = build_reviews_form(reviews_params: reviews_params, user: @verified_user)

            expect(reviews_form.valid?).to eq(true)
            expect{reviews_form.save}.not_to change{Review.active.count}
            expect(Review.active.first.comment).to eq(comment)
            expect(Review.inactive.first).to eq(@existing_review)
          end
        end

        context "with one invalid saving of a review" do
          it "should return false" do
            create(:alameda_high_school, id: 1)
            create(:review_question, id: 1)
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

  describe "#review_params" do
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
    it "should return hash with reviews hash and reviews saving message" do
      reviews_form = build_reviews_form
      allow(reviews_form).to receive(:reviews_hash).and_return("reviews_hash")
      allow(reviews_form).to receive(:reviews_saving_message).and_return("message")
      allow(reviews_form).to receive(:user_reviews).and_return("user_reviews")
      result_hash  = {
        reviews: "reviews_hash",
        message: "message",
        user_reviews: "user_reviews"
      }
      expect(reviews_form.hash_result).to eq(result_hash)
    end
  end

  describe "existing_reviews_with_comments_not_updated" do
    context "with user having existing reviews for school" do
      it "it should return only existing reviews not being updated by form" do
        school = create(:alameda_high_school, id: 1)
        verified_user = create(:verified_user)
        existing_review = create(:homework_review, user: verified_user, school_id: school.id)
        saved_review = build(:teacher_effectiveness_review, user: verified_user, school_id: school.id)
        reviews_form = build_reviews_form(user: verified_user)
        valid_reviews = [saved_review]
        allow(reviews_form).to receive(:saved_reviews).and_return(valid_reviews)

        expect(reviews_form.existing_reviews_with_comments_not_updated).to eq([existing_review])
      end
    end
    context "with no existing reviews" do
      it "should return empty array" do
        school = create(:alameda_high_school, id: 1)
        verified_user = create(:verified_user)
        saved_review = build(:teacher_effectiveness_review, user: verified_user, school_id: school.id)
        reviews_form = build_reviews_form(user: verified_user)
        valid_reviews = [saved_review]
        allow(reviews_form).to receive(:saved_reviews).and_return(valid_reviews)

        expect(reviews_form.existing_reviews_with_comments_not_updated).to eq([])
      end
    end
  end

  describe "all_active_reviews_with_comments" do
    context "with no existing reviews for school" do
      context "with form saving one review w/ comment and one w/out comment" do
        it "should return array only with review w/ comment" do
          reviews_form = build_reviews_form
          review_no_comment = build(:review, comment: nil)
          review_with_comment = build(:review)
          saved_reviews = [
            review_no_comment,
            review_with_comment
          ]
          allow(reviews_form).to receive(:saved_reviews)
            .and_return(saved_reviews)
          allow(reviews_form).
            to receive(:existing_reviews_with_comments_not_updated).and_return([])

          expect(reviews_form.all_active_reviews_with_comments)
            .to eq([review_with_comment])
        end
      end
    end
  end

  describe "#user_reviews" do
    it "should return user reviews struct" do
      create(:alameda_high_school, id: 1)
      verified_user = create(:verified_user)
      saved_review = create(:teacher_effectiveness_review, user: verified_user, school_id: 1)
      reviews_form = build_reviews_form
      valid_reviews = [saved_review]
      allow(reviews_form).to receive(:saved_reviews).and_return(valid_reviews)

      expect(reviews_form.user_reviews).to be_a(Hash)
    end
  end

  describe "#reviews_hash" do
    context "with no errors in saved questions" do
      it "should return reviews hash without errors" do
        create(:alameda_high_school, id: 1)
        verified_user = create(:verified_user)
        saved_review = create(:teacher_effectiveness_review, user: verified_user, school_id: 1)
        reviews_form = build_reviews_form
        valid_reviews = [saved_review]
        allow(reviews_form).to receive(:saved_reviews).and_return(valid_reviews)
        hash_result = {
          "#{saved_review.review_question_id}" => {
            comment: saved_review.comment,
            answer: saved_review.answer,
          }
        }

        expect(reviews_form.reviews_hash).to eq(hash_result)
      end
    end
    context "with one review with error" do
      it "should return reviews hash with one question with error" do
        create(:alameda_high_school, id: 1)
        verified_user = create(:verified_user)
        invalid_comment = "comment"
        saved_review = build(:teacher_effectiveness_review, comment: invalid_comment, user: verified_user, school_id: 1)
        saved_review.valid?
        reviews_form = build_reviews_form
        invalid_reviews = [saved_review]
        allow(reviews_form).to receive(:saved_reviews).and_return(invalid_reviews)
        hash_result = {
          saved_review.review_question_id => {
            comment: saved_review.comment,
            answer: saved_review.answer,
            errors: ["comment is too short (minimum is 7 words)"]
          }
        }.stringify_keys

        expect(reviews_form.reviews_hash).to eq(hash_result)
      end
    end
  end

  describe '#presence_of_review_question' do
    let (:reviews_form) { build_reviews_form }
    subject { reviews_form.presence_of_review_question }

    it 'is valid with a single review with a question' do
      create(:review_question, id: 1)
      review = Review.new
      review.review_question_id = 1
      allow(reviews_form).to receive(:reviews).and_return([review])
      subject
      expect(reviews_form.errors).to be_empty
    end

    it 'is invalid with a single review without a question' do
      review = Review.new
      review.review_question_id = 1
      allow(reviews_form).to receive(:reviews).and_return([review])
      subject
      expect(reviews_form.errors).to_not be_empty
    end

    it 'is valid with multiple reviews with questions' do
      create(:review_question, id: 1)
      create(:review_question, id: 2)
      review1 = Review.new
      review1.review_question_id = 1
      review2 = Review.new
      review2.review_question_id = 2
      allow(reviews_form).to receive(:reviews).and_return([review1, review2])
      subject
      expect(reviews_form.errors).to be_empty
    end

    it 'is invalid with multiple reviews where one is missing a question' do
      create(:review_question, id: 2)
      review1 = Review.new
      review1.review_question_id = 1
      review2 = Review.new
      review2.review_question_id = 2
      allow(reviews_form).to receive(:reviews).and_return([review1, review2])
      subject
      expect(reviews_form.errors).to_not be_empty
    end
  end

  def build_reviews_form(state: "CA",
                         school_id: "1",
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
                           answer_value: "5")
    [{
      "review_question_id"=>review_question_id,
      "comment"=> comment,
      "answer_value"=>answer_value,
    }]
  end
end

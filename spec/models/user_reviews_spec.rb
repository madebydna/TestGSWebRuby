require "spec_helper"

describe UserReviews do

  describe "#partition" do
    def user_reviews(reviews)
      UserReviews.new(reviews)
    end

    it "returns nil five_star_review if non exist" do
      school = build(:school)
      reviews = build_list(:review, 3, school: school)

      five_star_review, = UserReviews.new(reviews, school).partition
      expect(five_star_review).to be_nil
    end

    it "returns correct set of non-five-star reviews" do
      school = build(:school)
      reviews = build_list(:review, 3, school: school)
      _, other_reviews = UserReviews.new(reviews, school).partition
      expect(other_reviews).to eq(reviews)
    end

    it "raises an error if there are more than one five-star-review" do
      school = build(:school)
      reviews = build_list(:review, 3, school: school)
      five_star_reviews = build_list(:five_star_review, 2, school: school)
      combined_reviews = reviews + five_star_reviews

      expect { user_reviews(combined_reviews).partition }.to raise_error
    end

    it "returns correct five five review and no other reviews" do
      school = build(:school)
      reviews = [ build(:five_star_review, school: school) ]

      five_star_review, other_reviews = UserReviews.new(reviews, school).partition
      expect(five_star_review).to eq(reviews[0])
      expect(other_reviews).to be_empty
    end

    it "returns correct five star review and other reviews" do
      school = build(:school)
      reviews = [
        build(:review, school: school),
        build(:review, school: school),
        build(:five_star_review, school: school),
        build(:review, school: school),
      ]

      five_star_review, other_reviews = UserReviews.new(reviews, school).partition
      expect(other_reviews).to eq([reviews[0], reviews[1], reviews[3]])
      expect(five_star_review).to eq(reviews[2])
    end
  end

  describe "#review_to_hash" do
    let(:school) { build(:school) }
    let(:review) do
        build(:five_star_review, created: Date.parse("2012-01-01"), school: school)
    end
    subject do OpenStruct.new(
      UserReviews.new([review], school).review_to_hash(review)
      )
    end

    its(:comment) { is_expected.to eq(review.comment) }
    its(:id) { is_expected.to eq(review.id) }
    its(:topic_label) { is_expected.to eq(SchoolProfileReviewDecorator.decorate(review).topic_label) }
    its(:answer) { is_expected.to eq(review.answer) }
  end

  describe "#build_struct" do
    let(:school) { build(:school) }
    let(:reviews) do
      [
        build(:five_star_review, created: Date.parse("2012-01-01"), school: school),
        build(:teacher_effectiveness_review, school: school, created: Date.parse("2011-01-01")),
        build(:homework_review, school: school, created: Date.parse("2013-01-01")),
      ]
    end
    let(:user_reviews) { UserReviews.new(reviews, school) }
    subject { OpenStruct.new(user_reviews.build_struct) }
    before do
      allow(user_reviews).to receive(:school_user_digest).and_return("blah")
    end

    its(:five_star_review) do
      is_expected.to be_a(Hash)
    end
    its("topical_reviews.size") { is_expected.to eq(2) }
    its(:most_recent_date) { is_expected.to eq("January 01, 2013") }
    its(:school_user_digest) { is_expected.to eq("blah") }
  end
end

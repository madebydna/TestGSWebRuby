require 'spec_helper'

describe SchoolProfiles::Reviews do

  describe '#partition' do
    def user_reviews(reviews)
      SchoolProfiles::UserReviews.new(reviews)
    end

    it 'returns nil five_star_review if non exist' do
      reviews = [
        double(review_question_id: 2),
        double(review_question_id: 3),
        double(review_question_id: 4)
      ]
      five_star_review, _ = user_reviews(reviews).partition
      expect(five_star_review).to be_nil
    end

    it 'returns correct set of non-five-star reviews' do
      reviews = [
        double(review_question_id: 2),
        double(review_question_id: 3),
        double(review_question_id: 4)
      ]
      _, other_reviews = user_reviews(reviews).partition
      expect(other_reviews).to eq(reviews)
    end

    it 'raises an error if there are more than one five-star-review' do
      reviews = [
        double(review_question_id: 1),
        double(review_question_id: 1),
        double(review_question_id: 2),
        double(review_question_id: 3),
        double(review_question_id: 4)
      ]
      expect { user_reviews(reviews).partition }.to raise_error
    end
    
    it 'returns correct five five review and no other reviews' do
      reviews = [
        double(review_question_id: 1)
      ]
      five_star_review, other_reviews = user_reviews(reviews).partition
      expect(five_star_review).to eq(reviews[0])
      expect(other_reviews).to be_empty
    end

    it 'returns correct five star review and other reviews' do
      reviews = [
        double(review_question_id: 2),
        double(review_question_id: 3),
        double(review_question_id: 1),
        double(review_question_id: 4)
      ]
      five_star_review, other_reviews = user_reviews(reviews).partition
      expect(other_reviews).to eq([reviews[0], reviews[1], reviews[3]])
      expect(five_star_review).to eq(reviews[2])
    end
  end

  describe '#build_user_reviews_struct' do
    let(:reviews) do
      [
        double(
          created: Date.parse('2012-01-01'),
          review_question_id: 1
        ).as_null_object,
        double(
          created: Date.parse('2011-01-01'),
          review_question_id: 2
        ).as_null_object,
        double(
          created: Date.parse('2013-01-01'),
          review_question_id: 3
        ).as_null_object
      ]
    end
    subject do
      SchoolProfiles::Reviews.new(reviews).build_user_reviews_struct(SchoolProfiles::UserReviews.new(reviews))
    end
    its(:five_star_review) { is_expected.to be(reviews[0]) }
    its('topical_reviews.size') { is_expected.to eq(2) }
    its(:most_recent_date) { is_expected.to eq("January 01, 2013") }
  end

end

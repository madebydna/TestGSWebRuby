require 'spec_helper'

describe SchoolProfiles::Reviews do

  describe '#partition' do
    def user_reviews(reviews)
      SchoolProfiles::UserReviews.new(reviews)
    end

    it 'returns nil five_star_review if non exist' do
      reviews = [
        build(:review),
        build(:review),
        build(:review),
      ].extend(ReviewScoping).
      extend(ReviewCalculations)
      five_star_review, _ = user_reviews(reviews).partition
      expect(five_star_review).to be_nil
    end

    it 'returns correct set of non-five-star reviews' do
      reviews = [
        build(:review),
        build(:review),
        build(:review),
      ].extend(ReviewScoping).
          extend(ReviewCalculations)
      _, other_reviews = user_reviews(reviews).partition
      expect(other_reviews).to eq(reviews)
    end

    it 'raises an error if there are more than one five-star-review' do
      reviews = [
        build(:five_star_review),
        build(:five_star_review),
        build(:review),
        build(:review),
        build(:review),
      ].extend(ReviewScoping).
      extend(ReviewCalculations)
      expect { user_reviews(reviews).partition }.to raise_error
    end
    
    it 'returns correct five five review and no other reviews' do
      reviews = [
       build(:five_star_review)
      ].extend(ReviewScoping).
      extend(ReviewCalculations)
      five_star_review, other_reviews = user_reviews(reviews).partition
      expect(five_star_review).to eq(reviews[0])
      expect(other_reviews).to be_empty
    end

    it 'returns correct five star review and other reviews' do
      reviews = [
        build(:review),
        build(:review),
        build(:five_star_review),
        build(:review),
      ].extend(ReviewScoping).
      extend(ReviewCalculations)
      five_star_review, other_reviews = user_reviews(reviews).partition
      expect(other_reviews).to eq([reviews[0], reviews[1], reviews[3]])
      expect(five_star_review).to eq(reviews[2])
    end
  end

  describe '#build_user_reviews_struct' do
    let(:reviews) do
      [
        build(:five_star_review, created: Date.parse('2012-01-01')),
        build(:teacher_effectiveness_review, created: Date.parse('2011-01-01')),
        build(:homework_review, created: Date.parse('2013-01-01')),
      ].extend(ReviewScoping).
      extend(ReviewCalculations)
    end
    subject do
      OpenStruct.new(
        SchoolProfiles::Reviews.new(reviews).
        build_user_reviews_struct(SchoolProfiles::UserReviews.new(reviews))
      )
    end
    its(:five_star_review) do
      is_expected.to be_a(Hash)
    end
    its('topical_reviews.size') { is_expected.to eq(2) }
    its(:most_recent_date) { is_expected.to eq("January 01, 2013") }
  end

end

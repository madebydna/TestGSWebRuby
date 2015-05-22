require 'spec_helper'

describe ReviewsCaching::ReviewsSnapshotCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { ReviewsCaching::ReviewsSnapshotCacher.new(school) }
  let(:now) { Time.zone.now.to_s }
  let(:sample_reviews) do
    reviews = [
      FactoryGirl.build(:five_star_review, created: now, answer_value: '5'),
      FactoryGirl.build(:five_star_review, created: now, answer_value: '5')
    ]
    school_member = SchoolMember.new
    school_member.user_type = 'parent'
    reviews.each { |review| review.school_member = school_member }
    reviews
  end

  describe '#build_hash_for_cache' do
    let(:sample_reviews) do
      [
        FactoryGirl.build(:teacher_effectiveness_review, answer_value: 'agree'),
        FactoryGirl.build(:five_star_review, answer_value: 1),
        FactoryGirl.build(:five_star_review, answer_value: 1),
        FactoryGirl.build(:five_star_review, answer_value: 3),
        FactoryGirl.build(:five_star_review, answer_value: 5),
        FactoryGirl.build(:five_star_review, answer_value: 5),
        FactoryGirl.build(:five_star_review, answer_value: nil)
      ]
    end

    before do
      allow(school).to receive(:reviews).and_return(sample_reviews)
    end

    it 'builds the correct hash' do
      expected = {
          avg_star_rating: 3,
          num_ratings: 5,
          num_reviews: 7
      }

      expect(cacher.build_hash_for_cache).to eq(expected)
    end
  end

end

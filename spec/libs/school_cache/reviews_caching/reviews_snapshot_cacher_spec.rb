require 'spec_helper'

describe ReviewsCaching::ReviewsSnapshotCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { ReviewsCaching::ReviewsSnapshotCacher.new(school) }
  let(:sample_reviews) { [FactoryGirl.build(:school_rating), FactoryGirl.build(:school_rating)] }
  let(:most_recent_reviews) {
    [
        {comments: 'this is a valid comments value since it contains 15 words - including the hyphen',
         posted: Date.today.to_s,
         who: 'parent',
         quality: '5'},
        {comments: 'this is a valid comments value since it contains 15 words - including the hyphen',
         posted: Date.today.to_s,
         who: 'parent',
         quality: '5'}
    ]
  }

  describe '#build_hash_for_cache' do

    let(:review_snapshot) {
      Hashie::Mash.new({
                           star_counts:[0, 0, 4, 0, 2, 11],
                           rating_averages:{
                               overall:{avg_score:4, total:71, counter:17},
                               principal:{avg_score:4, total:44, counter:12},
                               teacher:{avg_score:4, total:48, counter:12},
                               parent:{avg_score:5, total:54, counter:12}},
                           review_filter_totals:{all:18, parent:13, student:3}})
    }

    it 'builds the correct hash' do
      allow_any_instance_of(School).to receive(:reviews).and_return(sample_reviews)
      allow_any_instance_of(ReviewsCaching::ReviewsSnapshotCacher).to receive(:review_snapshot).and_return(review_snapshot)
      allow_any_instance_of(ReviewsCaching::ReviewsSnapshotCacher).to receive(:most_recent_reviews).and_return(most_recent_reviews)
      expected = {
          avg_star_rating: review_snapshot.rating_averages.overall.avg_score,
          num_ratings: review_snapshot.rating_averages.overall.counter,
          num_reviews: review_snapshot.review_filter_totals.all,
          most_recent_reviews: most_recent_reviews,
          star_counts: review_snapshot.star_counts
      }

      expect(cacher.build_hash_for_cache).to eq(expected)
    end
  end

  describe '#most_recent_reviews' do

    it 'builds the correct hash' do

      allow_any_instance_of(ReviewsCaching::ReviewsSnapshotCacher).to receive(:school_reviews).and_return(sample_reviews)

      expect(cacher.most_recent_reviews).to eq(most_recent_reviews)
    end

    it 'gracefully skips schools without reviews' do
      allow_any_instance_of(ReviewsCaching::ReviewsSnapshotCacher).to receive(:school_reviews).and_return([])

      expect(cacher.most_recent_reviews).to eq([])
    end
  end

end

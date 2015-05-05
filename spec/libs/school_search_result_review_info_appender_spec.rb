require 'spec_helper'

describe SchoolSearchResultReviewInfoAppender do

  describe '.add_review_info_to_search_results!' do
    context 'with solr results containing school ID and state' do
      let(:appender) { SchoolSearchResultReviewInfoAppender.new(solr_results) }
      let(:solr_results) do
        [
          SchoolSearchResult.new({
            'school_database_state' => 'CA',
            'school_id' => 1,
            'school_review_count_ruby' => 1, # old value from Solr. We want to test that this isn't being used
            'community_rating' => 1
          }),
          SchoolSearchResult.new({
            'school_database_state' => 'CA',
            'school_id' => 2,
            'school_review_count_ruby' => 1, # old value from Solr. We want to test that this isn't being used
            'community_rating' => 1
          })
        ]
      end
      subject { appender.add_review_info_to_school_search_results! }
      before do
        allow(appender).to receive(:school_cache_results) do
          query_results = [1, 2].map do |id|
            school_cache = SchoolCache.new
            school_cache.state = 'CA'
            school_cache.school_id = id
            school_cache.name = 'reviews_snapshot'
            school_cache.value = {
              'num_reviews' => 4,
              'avg_star_rating' => 5
            }.to_json
            school_cache
          end
          SchoolCacheResults.new('reviews_snapshot', query_results)
        end
      end

      it 'should not use number of reviews received by Solr' do
        subject.each do |result|
          expect(result.review_count).to_not eq(1)
        end
      end

      it 'should use correct number of reviews' do
        subject.each do |result|
          expect(result.review_count).to eq(4)
        end
      end

      it 'should not use number of reviews received by Solr' do
        subject.each do |result|
          expect(result.community_rating).to_not eq(1)
        end
      end

      it 'should use correct number of star rating' do
        subject.each do |result|
          expect(result.community_rating).to eq(5)
        end
      end
    end
  end

end




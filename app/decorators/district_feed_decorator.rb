class DistrictFeedDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :district_cache
  delegate_all

  include GradeLevelConcerns

  def entity_type
    'district'
  end

  def feed_test_scores
    @_feed_test_scores ||= FeedTestScoresCacheHash.new(
      district_cache.cache_data['feed_test_scores'] || {}
    )
  end



end

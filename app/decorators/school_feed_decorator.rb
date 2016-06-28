class SchoolFeedDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :school_cache
  delegate_all

  include GradeLevelConcerns

  def entity_type
    'school'
  end

  def feed_test_scores
    @_feed_test_scores ||= FeedTestScoresCacheHash.new(
      school_cache.cache_data['feed_test_scores']
    )
  end

end
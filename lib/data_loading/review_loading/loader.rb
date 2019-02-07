class ReviewLoading::Loader < ReviewLoading::Base

  CACHE_KEY = 'reviews_snapshot'
  DATA_TYPE = 'school_reviews'
  ACTION_TRIGGER_MSS = 'trigger_mss'

  def load!
    updates.each do |update|
      next if update.blank?

      review_update = ReviewLoading::Update.new(data_type, update)

      school = School.on_db(review_update.entity_state.to_s.downcase.to_sym).find(review_update.entity_id)

      begin
        if review_update.action == ACTION_BUILD_CACHE
          # do nothing
        elsif review_update.action == ACTION_TRIGGER_MSS
          ReviewPublishedMssEmail.new(school, review_update.review_snippet).trigger_email
        end
      rescue Exception => e
        raise e.message
      ensure
        unless census_update.action == ACTION_TRIGGER_MSS
          Cacher.create_caches_for_data_type(school, DATA_TYPE)
        end
      end
    end
  end
end
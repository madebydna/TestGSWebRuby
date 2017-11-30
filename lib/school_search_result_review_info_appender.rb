class SchoolSearchResultReviewInfoAppender

  attr_reader :solr_results
  REVIEW_INFO_CACHE_KEY = 'reviews_snapshot'

  def self.add_review_info_to_school_search_results!(solr_results)
    SchoolSearchResultReviewInfoAppender.new(solr_results).add_review_info_to_school_search_results!
  end

  def initialize(solr_results)
    @solr_results = solr_results
  end

  def school_search_results
    solr_results
  end

  def state_ids
    school_search_results.each_with_object({}) do |school_search_result, state_map|
      (state_map[school_search_result.database_state.first.upcase] ||= []) << school_search_result.id
    end
  end

  def add_review_info_to_school_search_results!
    return unless solr_results.present?

    school_search_results.each do |school_search_result|
      school_id = school_search_result.id
      state = school_search_result.database_state.first.upcase
      review_cache_object = review_cache_object_for_school(state, school_id)
      if review_cache_object
        school_search_result.review_count = review_cache_object.num_reviews
        school_search_result.community_rating = review_cache_object.star_rating
      end
    end
    school_search_results
  end

  def school_cache_results
    return nil unless state_ids.present?
    @school_cache_results ||= (
    query = SchoolCacheQuery.new.include_cache_keys(REVIEW_INFO_CACHE_KEY)
    state_ids.each do |state, id_list|
      query = query.include_schools(state, id_list)
    end
    query_results = query.query_and_use_cache_keys
    SchoolCacheResults.new(REVIEW_INFO_CACHE_KEY, query_results)
    )
  end

  def review_cache_object_for_school(state, school_id)
    return nil unless state.present? && school_id.present? && school_cache_results.present?

    school_cache_results.get_cache_object_for_school(state, school_id)
  end
end
require_relative '../feed_config/feed_constants'

module Feeds
  module FeedDataHelper
    include Feeds::FeedConstants

    def get_school_batches(state,school_ids,batch_size)
      schools_in_feed = get_schools_in_feed(state,school_ids)
      school_batches = []
      schools_in_feed.each_slice(batch_size.to_i) do |slice|
        school_batches.push(slice)
      end
      Feeds::FeedLog.log.debug "Total Schools in database for #{state} : #{schools_in_feed.size}"
      Feeds::FeedLog.log.debug "School Batch Size #{batch_size}"
      Feeds::FeedLog.log.debug "Total Schools Batches Feed #{school_batches.size}"
      school_batches
    end

    def get_schools_in_feed(state,school_ids)
      if school_ids.present?
        schools_in_feed = School.on_db(state.downcase.to_sym).where(:id => school_ids).active
      else
        schools_in_feed = School.on_db(state.downcase.to_sym).all.active
      end
      schools_in_feed
    end

    def get_district_batches(state,district_ids,batch_size)
      districts_in_feed = get_districts_in_feed(state,district_ids)
      district_batches = []
      districts_in_feed.each_slice(batch_size.to_i) do |slice|
        district_batches.push(slice)
      end
      Feeds::FeedLog.log.debug "Total Districts in database for #{state} : #{districts_in_feed.size}"
      Feeds::FeedLog.log.debug "District Batch Size #{batch_size}"
      Feeds::FeedLog.log.debug "Total Districts Batches Feed #{district_batches.size}"
      district_batches
    end

    def get_districts_in_feed(state,district_ids)
      if district_ids.present?
        districts_in_feed = District.on_db(state.downcase.to_sym).where(:id => district_ids).active
      else
        districts_in_feed = District.on_db(state.downcase.to_sym).all.active
      end
      districts_in_feed
    end

    def get_schools_batch_cache_data(school_batch)
      query = SchoolCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
      school_batch.each do |school|
        query = query.include_schools(school.state, school.id)
      end
      query_results = query.query_and_use_cache_keys
      school_cache_results = SchoolCacheResults.new(FEED_CACHE_KEYS, query_results)
      schools_with_cache_results= school_cache_results.decorate_schools(school_batch)
      schools_with_cache_results.map do |school|
              SchoolFeedDecorator.decorate(school)
            end
    end

    def get_districts_batch_cache_data(district_batch)
      query = DistrictCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
      district_batch.each do |district|
        query = query.include_districts(district.state, district.id)
      end
      query_results = query.query_and_use_cache_keys
      district_cache_results = DistrictCacheResults.new(FEED_CACHE_KEYS, query_results)
      districts_with_cache_results= district_cache_results.decorate_districts(district_batch)
      districts_with_cache_results.map do |district|
              DistrictFeedDecorator.decorate(district)
      end
    end
  end
end
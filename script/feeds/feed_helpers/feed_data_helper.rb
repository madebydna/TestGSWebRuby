require_relative '../../feeds/feed_config/feed_constants'

module FeedDataHelper
  include FeedConstants

  def get_school_batches
    state =@state
    school_ids = @school_ids
    if school_ids.present?
      schools_in_feed = School.on_db(state.downcase.to_sym).where(:id => school_ids)
    else
      schools_in_feed = School.on_db(state.downcase.to_sym).all
    end
    school_batches = []
    schools_in_feed.each_slice(@batch_size.to_i) do |slice|
      school_batches.push(slice)
    end
    puts "Total Schools in State #{schools_in_feed.size}"
    puts "School Batch Size #{@batch_size}"
    puts "Total Schools Batches Feed #{school_batches.size}"
    school_batches
  end

  def get_district_batches
    state =@state
    district_ids = @district_ids
    if district_ids.present?
      districts_in_feed = District.on_db(state.downcase.to_sym).where(:id => district_ids)
    else
      districts_in_feed = District.on_db(state.downcase.to_sym).all
    end
    district_batches = []
    districts_in_feed.each_slice(@batch_size.to_i) do |slice|
      district_batches.push(slice)
    end
    puts "Total Districts in State #{districts_in_feed.size}"
    puts "District Batch Size #{@batch_size}"
    puts "Total Districts Batches Feed #{district_batches.size}"
    district_batches
  end

  def get_schools_batch_cache_data(school_batch)
    query = SchoolCacheQuery.new.include_cache_keys(FEED_CACHE_KEYS)
    school_batch.each do |school|
      query = query.include_schools(school.state, school.id)
    end
    query_results = query.query_and_use_cache_keys
    school_cache_results = SchoolCacheResults.new(FEED_CACHE_KEYS, query_results)
    schools_with_cache_results= school_cache_results.decorate_schools(school_batch)
    schools_decorated_with_cache_results = schools_with_cache_results.map do |school|
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
    districts_decorated_with_cache_results = districts_with_cache_results.map do |district|
      DistrictFeedDecorator.decorate(district)
    end
  end
end
module Feeds
  class FeedEntityReader
    include Feeds::FeedConstants

    attr_reader :state, :model, :ids, :batch_size
    def initialize(state, model, options = {})
      @state = state
      @model = model
      @ids = options[:ids] || []
      @batch_size = options[:batch_size].to_i || 100
    end

    def self.for_districts(state, options = {})
      new(state, District, options)
    end

    def self.for_schools(state, options = {})
      new(state, School, options)
    end

    def each_batch_with_index
      batches.each_with_index do |batch, index|
        yield(objects_with_cache_data(batch), index)
      end
    end

    def objects_with_cache_data(batch)
      cache_query_class = Object.const_get("#{model}CacheQuery")
      cache_results_class = Object.const_get("#{model}CacheResults")
      feed_decorator_class = Object.const_get("#{model}FeedDecorator")

      query = cache_query_class.new.include_cache_keys(FEED_CACHE_KEYS)
      batch.each do |entity|
        query = query.send("include_#{model.name.downcase}s", entity.state, entity.id)
      end
      query_results = query.query_and_use_cache_keys
      cache_results = cache_results_class.new(FEED_CACHE_KEYS, query_results)
      schools_with_cache_results = cache_results.send("decorate_#{model.name.downcase}s", batch)
      schools_with_cache_results.map do |entity|
        feed_decorator_class.decorate(entity)
      end
    end

    def batches
      @_batches ||= entities.each_slice(batch_size).to_a
    end

    def total_entities
      batches.sum(&:size)
    end

    def entities
      if ids.present?
        model.on_db(state.downcase.to_sym).where(:id => ids).active
      else
        model.on_db(state.downcase.to_sym).all.active
      end
    end
  end
end
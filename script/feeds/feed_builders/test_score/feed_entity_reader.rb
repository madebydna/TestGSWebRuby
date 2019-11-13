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

    def each(&block)
      batches.each do |batch|
        objects_with_cache_data(batch).each(&block)
      end
    end

    # def objects_with_cache_data(batch)
    #   cache_query_class = Object.const_get("#{model}CacheQuery")
    #   cache_results_class = Object.const_get("#{model}CacheResults")
    #   feed_decorator_class = Object.const_get("#{model}FeedDecorator")
    # 
    #   query = cache_query_class.new.include_cache_keys(FEED_CACHE_KEYS)
    #   batch.each do |entity|
    #     query = query.send("include_#{model.name.downcase}s", entity.state, entity.id)
    #   end
    #   query_results = query.query_and_use_cache_keys
    #   cache_results = cache_results_class.new(FEED_CACHE_KEYS, query_results)
    #   objects_with_cache_results = cache_results.send("decorate_#{model.name.downcase}s", batch)
    #   objects_with_cache_results.map do |entity|
    #     feed_decorator_class.decorate(entity)
    #   end
    # end

    def objects_with_cache_data(id)
      keys = FeedConstants.const_get("DIRECTORY_FEED_#{@model.upcase}_CACHE_KEYS")
      qr = query_results(keys, id)
      cache_results_class = Object.const_get("#{@model}CacheResults")
      cache_results = cache_results_class.new(keys, qr)
      cache_results&.data_hash&.first&.second
    end

    def query_results(keys, id)
      if @model == "District"
        DistrictCache.include_cache_keys(keys).for_state_and_id(@state, id)
      else
        cache_query_class = Object.const_get("#{@model}CacheQuery")
        query = cache_query_class.new.include_cache_keys(keys)
        query = query.send("include_#{@model.downcase}s", @state, id)
        query.query_and_use_cache_keys
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
module Feeds
  class EntityDirectoryFeed
    include Feeds::FeedConstants

    attr_reader :state

    def initialize(state, ids, data_type, model )
      @state = state
      @model = model
      @ids = ids
      @data_type = data_type
    end

    def self.for_schools(state, ids, data_type)
      new(state, ids, data_type, 'School')
    end

    def self.for_districts(state, ids, data_type)
      new(state, ids, data_type, 'District')
    end

    def self.for_states(state, data_type)
      new(state, nil, data_type, 'State')
    end

    def each_result
      if block_given?
        @ids.each do |id|
          data = objects_with_cache_data(id)
          hash = DirectoryDataBuilder.build_data(data, @state, @model)
          yield(hash)
        end
      end
    end

    def objects_with_cache_data(id)
      cache_query_class = Object.const_get("#{@model}CacheQuery")
      cache_results_class = Object.const_get("#{@model}CacheResults")
      keys = FeedConstants.const_get("DIRECTORY_FEED_#{@model.upcase}_CACHE_KEYS")
      query = cache_query_class.new.include_cache_keys(keys)
      query = query.send("include_#{@model.downcase}s", @state, id)
      query_results = query.query_and_use_cache_keys
      cache_results = cache_results_class.new(keys, query_results)
      c = cache_results.data_hash if cache_results
      c.first.second if c && c.first
    end

  end
end
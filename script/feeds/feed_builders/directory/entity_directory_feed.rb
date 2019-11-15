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

    def state_result
      if block_given?
        yield(DirectoryStateDataBuilder.build_data(@state))
      end
    end

    def each_result
      if block_given?
        @ids.each do |id|
          data = objects_with_cache_data(id)
          hash = DirectoryDataBuilder.build_data(data, @state, @model) if data
          yield(hash)
        end
      end
    end

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
  end
end
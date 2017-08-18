module Feeds
  class EntityTestDataReader
    attr_reader :state, :entity_reader

    def initialize(state, entity_reader)
      @state = state
      @entity_reader = entity_reader
    end

    def each
      entity_reader.each do |entity|
        yield(entity_to_test_data_set_hashes(entity))
      end
    end

    def entity_to_test_data_set_hashes(entity)
      cache_hash = entity.feed_test_scores
      test_data_set_hashes = cache_hash.flatten
      test_data_set_hashes.map do |tdsh|
        tdsh[:universal_id] = TestCalculations.calculate_universal_id(state, entity.entity_type, entity.id)
        TestDataSetHashDecorator.new(state, tdsh)
      end
    end
  end

  class SchoolTestDataReader < EntityTestDataReader
    def initialize(state, *args)
      super(state, FeedEntityReader.for_schools(state, *args))
    end
  end

  class DistrictTestDataReader < EntityTestDataReader
    def initialize(state, *args)
      super(state, FeedEntityReader.for_districts(state, *args))
    end
  end
end

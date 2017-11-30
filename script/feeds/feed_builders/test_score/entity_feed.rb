module Feeds
  class EntityFeed
    include Feeds::FeedConstants

    attr_reader :state, :test_data_reader, :data_type

    def initialize(state, test_data_reader, data_type)
      @test_data_reader = test_data_reader
      @data_type = data_type
      @state = state
    end

    def self.for_schools(state, ids, data_type, batch_size)
      test_data_reader = SchoolTestDataReader.new(state, ids: ids, batch_size: batch_size)
      new(state, test_data_reader, data_type)
    end

    def self.for_districts(state, ids, data_type, batch_size)
      test_data_reader = DistrictTestDataReader.new(state, ids: ids, batch_size: batch_size)
      new(state, test_data_reader, data_type)
    end

    def self.for_states(state, data_type)
      test_data_reader = StateTestDataReader.new(state, data_type)
      new(state, test_data_reader, data_type)
    end

    def each_result
      test_data_reader.each do |test_data_sets|
        test_data_sets.select! { |tds| tds.breakdown_name == 'All' || tds.breakdown_name == 'All students' } if data_type == WITH_NO_BREAKDOWN
        hashes = test_data_sets.map { |tds| format(tds) }
        yield(hashes)
      end
    end

    def format(test_data_set)
      test_data_hash = {
        universal_id: test_data_set.try(:universal_id),
        test_id: test_data_set.test_id,
        year: test_data_set.year,
        subject_name: test_data_set.subject,
        grade_name: test_data_set.grade,
        level_code_name: test_data_set.level_code,
        score: test_data_set.test_score,
        proficiency_band_id: test_data_set.proficiency_band_id,
        proficiency_band_name: test_data_set.proficiency_band_name,
        number_tested: test_data_set.number_tested
      }
      if data_type == WITH_ALL_BREAKDOWN
        test_data_hash.merge!({
                                breakdown_id: test_data_set.breakdown_id,
                                breakdown_name: test_data_set.breakdown_name
                              })
      end
      test_data_hash[:universal_id] ||= TestCalculations.calculate_universal_id(state)

      test_data_hash
    end

    def name
      self.class.name
    end

    def debug(msg)
      msg = "[#{state}] #{name} batch: " < msg
      Feeds::FeedLog.log.debug(msg)
    end
  end
end
module Feeds
  class StateInfoFeed

    include Feeds::FeedConstants

    attr_reader :state, :data_type

    def initialize(state, data_type)
      @state = state
      @data_type = data_type
    end

    def test_descriptions
      TestDescription.where(state: state)
    end

    def new_test_description_decorator(test_description)
      TestDescriptionDecorator.new(test_description)
    end

    def to_hashes
      hashes = test_descriptions.map do |test_description|
        new_test_description_decorator(test_description).to_hash
      end
      hashes.compact
    end

    class TestDescriptionDecorator
      attr_reader :test_description

      def initialize(test_description)
        @test_description = test_description
      end

      def state
        test_description.state
      end

      def test_data_type
        if defined?(@_test_data_type)
          return @_test_data_type
        end
        @_test_data_type = TestDataType.find(test_description.data_type_id)
      end

      def test_data_set
        if defined?(@_test_data_set)
          return @_test_data_set
        end
        query = TestDataSet.on_db(state.downcase.to_sym).
          with_data_type(test_data_type).
          latest_active_feed_data_set
        query = query.first if query.respond_to?(:first)
        @_test_data_set = query
      end

      def id
        state.upcase + test_data_type.id.to_s.rjust(5, '0')
      end

      def to_hash
        return nil unless test_data_set != nil && test_data_type != nil
        {
          id: id,
          test_name: test_data_type.description,
          test_abbrv: test_data_type.name,
          scale: test_description.scale,
          most_recent_year: test_data_set.year,
          level_code: test_data_set.level_code,
          description: test_description.description
        }
      end
    end

  end

end
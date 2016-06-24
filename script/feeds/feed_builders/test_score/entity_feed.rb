module Feeds
  class EntityFeed
    attr_reader :state, :ids, :data_type, :batch_size, :entity_reader

    def initialize(state, ids, data_type, batch_size, entity_reader, data_builder_class)
      @state = state
      @ids = ids
      @data_type = data_type
      @batch_size = batch_size
      @entity_reader = entity_reader
      @data_builder_class = data_builder_class
    end

    def self.for_schools(state, ids, data_type, batch_size)
      entity_reader = FeedEntityReader.for_schools(state, ids: ids, batch_size: batch_size)
      data_builder_class = SchoolDataBuilder
      new(state, ids, data_type, batch_size, entity_reader, data_builder_class)
    end

    def self.for_districts(state, ids, data_type, batch_size)
      entity_reader = FeedEntityReader.for_districts(state, ids: ids, batch_size: batch_size)
      data_builder_class = DistrictDataBuilder
      new(state, ids, data_type, batch_size, entity_reader, data_builder_class)
    end

    def new_data_builder(*args)
      @data_builder_class.new(*args)
    end

    def each_result
      debug "Batch size: #{batch_size}"
      debug "Total batches: #{entity_reader.batches.size}"
      debug "Total models in database: #{entity_reader.total_entities}"
      entity_reader.each_batch_with_index do |batch, index|
        debug "Starting at #{Time.now} for batch number #{index+1}"

        data = batch.map do |entity|
          new_data_builder(state, data_type, entity).to_hashes
        end.flatten

        yield(data)

        debug "Finishing at #{Time.now} for batch number #{index+1}"
      end
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
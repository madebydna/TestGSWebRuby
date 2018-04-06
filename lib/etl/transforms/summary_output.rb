# frozen_string_literal: true

class SummaryOutput < GS::ETL::Source

  attr_accessor :summary_output_fields

  def initialize(summary_output_fields)
    self.summary_output_fields = summary_output_fields
    @hash = {}
  end

  # Example Data Structure created by process method:
  #
  # {
  #   school: {
  #     breakdown: {
  #       asian: [state_id_1, state_id_2],
  #       white: [state_id_1, state_id_2, state_id_3]
  #     },
  #     grade : {
  #       11: [state_id_1, state_id_3]
  #     }
  #   }
  # }

  def process(row)
    entity_level = row[:entity_level].to_sym
    @hash[entity_level] ||= {}
    summary_output_fields.each do |field|
      field_value = row[field]
      @hash[entity_level][field] ||= {}
      @hash[entity_level][field][field_value] ||= []
      @hash[entity_level][field][field_value] << row[:state_id]
    end
    nil
  end

  def each
    @hash.each do |entity_level,entity_hash|
      entity_hash.each do |field,value_hash|
        value_hash.each do |value, count|
          yield(
              {
                  entity_level: entity_level,
                  field: field,
                  value: value,
                  count: count.uniq.length
              }
          )
        end
      end
    end
  end

end
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
    entity_type = row[:entity_type].to_sym
    @hash[entity_type] ||= {}
    summary_output_fields.each do |field|
      field_value = row[field]
      @hash[entity_type][field] ||= {}
      @hash[entity_type][field][field_value] ||= []
      @hash[entity_type][field][field_value] << row[:state_id]
    end
    nil
  end

  def each
    @hash.each do |entity_type,entity_hash|
      entity_hash.each do |field,value_hash|
        value_hash.each do |value, count|
          yield(
              {
                  entity_type: entity_type,
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
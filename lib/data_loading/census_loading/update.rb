class CensusLoading::Update

  include CensusLoading::Breakdowns
  include CensusLoading::Subjects

  attr_accessor :breakdown, :breakdown_id, :data_set_attributes, :data_type, :data_type_id,
                :entity_id, :entity_id_type, :entity_state, :entity_type, :grade, :shard,
                :state, :subject, :subject_id, :update_blob, :value, :value_class,
                :value_record_attributes, :value_type, :year, :action

  def initialize(data_type, update_blob)
    @data_type = data_type
    @update_blob = update_blob

    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    parse_attributes!

    validate_update
  end

  def parse_attributes!
    @shard = entity_state.to_s.downcase.to_sym
    @entity_type = entity_type.to_s.downcase.to_sym
    @entity_id_type = "#{entity_type.downcase}_id".to_sym

    @value_type = data_type.value_type

    @data_set_attributes = data_set_attributes

    @value_class = "CensusData#{entity_type.to_s.titleize}Value".constantize
  end

  def data_set_attributes
    @data_set_attributes ||=
        {
                    year: year.to_i, # Defaults to 0
                   grade: grade.nil? ? nil : grade.to_s,
              subject_id: convert_subject_to_id(subject) || subject_id,
            breakdown_id: convert_breakdown_to_id(breakdown) || breakdown_id,
            data_type_id: data_type.id
        }
  end

  def validate_update
    if entity_state.blank? || entity_type.blank?
      raise 'Every census update must have an entity_state and entity_type specified'
    end
    if entity_id.blank? && entity_type != :state
      raise 'Non-state level updates must have an entity_id specified'
    end
    if value.blank?
      raise 'Every census update must have a value'
    end
  end
end
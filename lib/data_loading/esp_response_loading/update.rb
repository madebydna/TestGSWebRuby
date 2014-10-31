class EspResponseLoading::Update

  attr_accessor :data_type, :entity_id, :entity_state, :shard, :state, :update_blob, :value, :member_id, :source

  def initialize(data_type, update_blob, source)
    @data_type = data_type
    @update_blob = update_blob
    @source = source

    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    parse_attributes!

    validate_update
  end

  def parse_attributes!
    @shard = entity_state.to_s.downcase.to_sym

    @attributes = attributes
  end

  def attributes
    @attributes ||=
        {
            school_id: entity_id,
            response_key: data_type,
            response_value: value
        }
  end

  def validate_update
    raise 'Every esp response update must have an entity_state specified' if entity_state.blank?
    raise 'Every esp response update must have a data_type specified' if data_type.blank?
    raise 'Every esp response update must have an value specified' if value.blank?
    raise 'Every esp response update must have a member_id specified' if member_id.blank?
    raise 'Every esp response update must have a entity_id specified' if entity_id.blank?
  end
end
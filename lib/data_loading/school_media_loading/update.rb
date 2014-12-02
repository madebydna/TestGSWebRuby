class SchoolMediaLoading::Update

  attr_accessor :data_type, :entity_id, :entity_state, :state, :update_blob, :value, :member_id, :source, :action

  def initialize(data_type, update_blob)
    @data_type = data_type
    @update_blob = update_blob

    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    validate_update
  end

  def validate_update
    raise 'Every school media update must have an entity_state (school state) specified' if entity_state.blank?
    raise 'Every school media update must have a data_type specified' if data_type.blank?
    raise 'Every school media update must have a entity_id (school id) specified' if entity_id.blank?
  end
end
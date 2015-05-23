class SchoolLoading::Update

  attr_accessor :data_type, :entity_id, :entity_state, :state, :update_blob, :value, :member_id, :source,  :created

  def initialize(data_type, update_blob)

    @data_type = data_type
    @update_blob = update_blob
    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    validate_update
  end



  def validate_update
    raise 'Every school update must have an entity_state specified' if entity_state.blank?
    raise 'Every school update must have a data_type specified' if data_type.blank?
    raise 'Every school update must have a entity_id specified' if entity_id.blank?
    raise 'Every school update must have an value specified' if value.blank?
    raise 'Every school update must have a member_id specified' if member_id.blank?
    raise 'Every school update must have a created specified' if created.blank?

  end
end

class ReviewLoading::Update

  attr_accessor :data_type, :entity_id, :entity_state, :state, :update_blob, :value, :member_id, :source, :action

  def initialize(data_type, update_blob, source)
    @data_type = data_type
    @update_blob = update_blob
    @source = source

    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    validate_update

    parse_attributes!
  end

  def parse_attributes!
    @attributes = attributes
  end

  def attributes
    @attributes ||=
        {
            school_id: entity_id,
            member_id: member_id
        }
  end

  def validate_update
    raise 'Every review update must have an entity_state (school state) specified' if entity_state.blank?
    raise 'Every review update must have a data_type specified' if data_type.blank?
    raise 'Every review update must have a entity_id (school id) specified' if entity_id.blank?
  end
end
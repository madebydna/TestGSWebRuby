class GsdataLoading::Update
  attr_accessor :data_type, :school_id, :state, :update_blob, :action

  def initialize(update_blob)
    @update_blob = update_blob
    set_up_attr_accessors
    validate
  end

  def set_up_attr_accessors
    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def state_db
    state.downcase.to_sym
  end

  def validate
    raise "Every gsdata update must have have a state specified" if state.blank?
    if school_id.blank?
      raise "Every gsdata update must have have a school_id specified"
    end
  end
end

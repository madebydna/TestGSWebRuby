# frozen_string_literal: true

class DirectoryLoading::Update

  attr_accessor :data_type, :update_blob, :created, :action, :entity_type, :entity_id, :entity_state, :shard

  def initialize(data_type, update_blob)
    @data_type   = data_type
    @update_blob = update_blob
    @created     = created
    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    parse_attributes!
  end

  def parse_attributes!
    @shard = entity_state.to_s.downcase.to_sym
    self.entity_type = self.entity_type.to_s.downcase.to_sym
  end

  def entity
    return @_entity if defined?(@_entity)
    @_entity ||= begin
      entity_type == :state ? nil : entity_type.to_s.titleize.constantize.on_db(shard).find(entity_id)
    end
  end
end
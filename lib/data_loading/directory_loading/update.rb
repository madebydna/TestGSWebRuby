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

    @shard = entity_state.to_s.downcase.to_sym
    @entity_type = entity_type.to_s.downcase.to_sym
    @model = entity_type.to_s.titleize.constantize unless @entity_type == :state
  end

  def entity
    return @_entity if defined?(@_entity)
    @_entity ||= begin
      @model&.on_db(shard)&.find(entity_id)
    end
  end
end
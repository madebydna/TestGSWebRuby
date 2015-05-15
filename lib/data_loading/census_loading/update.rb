class CensusLoading::Update

  include CensusLoading::Breakdowns
  include CensusLoading::Subjects

  attr_accessor :breakdown, :breakdown_id, :data_set_attributes, :data_type, :data_type_id,
                :entity_id, :entity_id_type, :entity_state, :entity_type, :grade, :shard,
                :state, :subject, :subject_id, :source, :update_blob, :value, :value_class,
                :value_record_attributes, :value_type, :year, :action, :created

  DEFAULT_SOURCE = 'Manually entered by a school official'

  def initialize(data_type, update_blob)
    @data_type = data_type
    @update_blob = update_blob
    @created     = created
    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    validate_update

    parse_attributes!
  end

  def parse_attributes!
    @shard = entity_state.to_s.downcase.to_sym
    self.entity_type = self.entity_type.to_s.downcase.to_sym
    @entity_id_type = "#{entity_type.downcase}_id".to_sym
    @value = SafeHtmlUtils.html_escape_allow_entities(@value) if @value.is_a?(String)
    @source = DEFAULT_SOURCE if source.blank?

    unless action == CensusLoading::Loader::ACTION_BUILD_CACHE
      @value_type = data_type.value_type
      @subject_id = nil if @subject_id == 'null'
      @breakdown_id = nil if @breakdown_id == 'null'
      @data_set_attributes = data_set_attributes
      @value_class = "CensusData#{entity_type.to_s.titleize}Value".constantize
    end
  end

  def data_set_attributes
    @data_set_attributes ||=
        {
                    year: year.to_i, # Defaults to 0
                   grade: grade.blank? ? nil : grade.to_s,
              subject_id: convert_subject_to_id(subject) || subject_id,
            breakdown_id: convert_breakdown_to_id(breakdown) || breakdown_id,
            data_type_id: data_type.id
        }
  end

  def census_description_attributes
    @census_description_attributes ||= {
        state: entity_state,
        source: source,
        type: entity_type
    }
  end

  def validate_update
    if entity_state.blank? || entity_type.blank?
      raise 'Every census update must have an entity_state and entity_type specified'
    end
    if entity_id.blank? && entity_type.to_sym != :state
      raise 'Non-state level updates must have an entity_id specified'
    end
    if value.nil?
      raise 'Every census update must have a value' unless action == CensusLoading::Loader::ACTION_BUILD_CACHE
    end
  end

  def created_before?(time)
    time <  @created
  end

  def created_after?(time)
    time >  @created
  end

end

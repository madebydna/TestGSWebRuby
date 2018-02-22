# frozen_string_literal: true

require 'json-schema'

class GsdataLoading::Update
  attr_accessor :data_type, :school_id, :state, :update_blob, :action, :source, :entity_level, :state_id, :district_id

  SCHEMA = {
      'type' => 'object',
      'required' => %w[value state data_type_id active],
      'properties' => {
          'state' => {'type' => 'string'},
          'data_type_id' => {'type' => 'integer'},
          'school_id' => {'type' => 'string'},
          'district_id' => {'type' => 'string'},
          'cohort_count' => {'type' => 'string'},
          'active' => {'type' => 'integer'},
          'grade' => {'type' => 'string'},
          'proficiency_band_id' => {'type' => 'string'},
          'breakdowns' => {
              'type' => 'array',
              'items' => {
                  'type' => 'object',
                  'required' => %w(id),
                  'properties' => {
                      'id' => {'type' => 'integer'},
                      'name' => {'type' => 'string'},
                      'tags' => {
                          'type' => 'array',
                          'items' => {
                              'type' => 'object',
                              'required' => %w[name active],
                              'properties' => {
                                  'name' => {'type' => 'string'},
                                  'active' => {'type' => 'integer'}
                              }
                          }
                      }
                  }
              }
          },
          'academics' => {
              'type' => 'array',
              'items' => {
                  'type' => 'object',
                  'required' => %w(id),
                  'properties' => {
                      'id' => {'type' => 'integer'},
                      'name' => {'type' => 'string'},
                      'tags' => {
                          'type' => 'array',
                          'items' => {
                              'type' => 'object',
                              'required' => %w[name active],
                              'properties' => {
                                  'name' => {'type' => 'string'},
                                  'active' => {'type' => 'integer'}
                              }
                          }
                      }
                  }
              }
          },
          'source' => {
              'type' => 'object',
              'required' => %w[source_name date_valid notes],
              'properties' => {
                  'source_name' => {'type' => 'string'},
                  'date_valid' => {'type' => 'string'},
                  'notes' => {'type' => 'string'},
              }
          }
      }
  }

  def initialize(update_blob)
    @update_blob = update_blob
    set_up_attr_accessors
    validate
  end

  def validate
    JSON::Validator.validate!(SCHEMA, @update_blob)
    raise 'Every gsdata update must have have a state specified' if state.blank?
  end

  def source_replace_into_and_return_id
    Gsdata::Source.on_db(:gsdata_rw) do
      source = Gsdata::Source
        .from_hash(@update_blob['source'])
        .replace_into_and_return_object
      source.id
    end
  end

  def set_up_attr_accessors
    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def state_db
    state.downcase.to_sym
  end

  def create( school, district )
    @source_id = source_replace_into_and_return_id
    @data_value_id = insert_data_value_return_id( school, district )
    insert_data_value_to_academics
    insert_data_value_to_breakdowns
  end

  def insert_data_value_return_id( school, district )
    s = DataValue.new
    s.value = @value
    s.state = @state
    school_id = nil
    district_id = nil
    if school
      school_id = school.id
      district_id = school.district_id
    elsif district
      district_id = district.id
    end
    s.school_id = school_id
    s.district_id = district_id
    s.configuration = @configuration
    s.data_type_id = @data_type_id
    s.proficiency_band_id = @proficiency_band_id
    s.cohort_count = @cohort_count
    s.grade = @grade
    s.active = @active
    s.source_id = @source_id
    DataValue.on_db(:gsdata_rw) do
      unless s.save!
        GSLogger.error(:gsdata_load, nil, message: 'gsdata DataValue failed to save', vars: {
            value: @value,
            state: @state,
            school_id: school_id,
            district_id: district_id,
            data_type_id: @data_type_id,
            proficiency_band_id: @proficiency_band_id,
            cohort_count: @cohort_count,
            grade: @grade,
            active: @active
        })
      end
    end

    s.id
  end

  def insert_data_value_to_academics
    return if @academics.blank?
    @academics.each do |academic|
      s = DataValuesToAcademic.new
      s.data_value_id = @data_value_id
      s.academic_id = academic['id']
      DataValuesToAcademic.on_db(:gsdata_rw) do
        unless s.save!
          GSLogger.error(:gsdata_load, nil, message: 'gsdata DataValueToAcademics failed to save', vars: {
              academic_id: academic['id'],
              data_value_id: @data_value_id
          })
        end
      end
    end
  end

  def insert_data_value_to_breakdowns
    return if @breakdowns.blank?
    @breakdowns.each do |breakdown|
      s = DataValuesToBreakdown.new
      s.data_value_id = @data_value_id
      s.breakdown_id = breakdown['id']
      DataValuesToBreakdown.on_db(:gsdata_rw) do
        unless s.save!
          GSLogger.error(:gsdata_load, nil, message: 'gsdata DataValueToBreakdowns failed to save', vars: {
              breakdown_id: breakdown['id'],
              data_value_id: @data_value_id
          })
        end
      end
    end
  end

end

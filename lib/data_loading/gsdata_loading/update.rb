# frozen_string_literal: true

require 'json-schema'

class GsdataLoading::Update
  attr_accessor :data_type, :school_id, :state, :update_blob, :action, :source

  SCHEMA = {
      'type' => 'object',
      'required' => %w[value state data_type_id active],
      'properties' => {
          'state' => {'type' => 'string'},
          'data_type_id' => {'type' => 'integer'},
          'school_id' => {'type' => 'integer'},
          'district_id' => {'type' => 'integer'},
          'cohort_count' => {'type' => 'integer'},
          'active' => {'type' => 'integer'},
          'grade' => {'type' => 'string'},
          'proficiency_band_id' => {'type' => 'integer'},
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
    raise 'Every gsdata update must have have a school_id specified' if school_id.blank?
  end

  def source_replace_into_and_return_id
    source = Source.from_hash(@update_blob['source']).replace_into
    source.id
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
    if @school
      school_id = school.id
      district_id = school.district_id
    elsif @district
      district_id = district.id
    end
    s.school_id = school_id
    s.district_id = district_id
    s.data_type_id = @data_type_id
    s.proficiency_band_id = @proficiency_band_id
    s.cohort_count = @cohort_count
    s.grade = @grade
    s.active = @active
    s.source_id = @source_id
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
    s.id
  end

  def insert_data_value_to_academics
    return if @update.academics.blank?
    @update.academics.each do |academic|
      s = DataValueToAcademic.new
      s.data_value_id = @data_value_id
      s.academic_id = academic.id
      unless s.save!
        GSLogger.error(:gsdata_load, nil, message: 'gsdata DataValueToAcademics failed to save', vars: {
            academic_id: academic.id,
            data_value_id: @data_value_id
        })
      end
    end
  end

  def insert_data_value_to_breakdowns
    return if @update.breakdowns.blank?
    @update.breakdowns.each do |breakdown|
      s = DataValueToBreakdown.new
      s.data_value_id = @data_value_id
      s.breakdown_id = breakdown.id
      unless s.save!
        GSLogger.error(:gsdata_load, nil, message: 'gsdata DataValueToBreakdowns failed to save', vars: {
            breakdown_id: breakdown.id,
            data_value_id: @data_value_id
        })
      end
    end
  end

  # def data_value
  #   now = Time.zone.now
  #   @_data_value ||= (
  #   DataValue.from_hash(update_hash).tap do |dv|
  #     dv.breakdowns = matching_breakdowns if matching_breakdowns
  #     dv.created = now
  #     dv.updated = now
  #     dv.source = Source.find_by(update_hash['source'])
  #   end
  #   )
  # end

  # def matching_breakdowns
  #   if defined?(@_matching_breakdowns)
  #     return @_matching_breakdowns
  #   end
  #   @_matching_breakdowns = (
  #   update_hash['breakdowns'].map do |hash|
  #     Breakdown.find_by_name_and_tags(
  #         hash['name'],
  #         hash['tags'].map { |h| h['tag'] }
  #     )
  #   end.compact
  #   )
  # end

end
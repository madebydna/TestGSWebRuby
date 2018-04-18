# frozen_string_literal: true

require 'json-schema'

class GsdataLoading::Update
  attr_accessor :state, :update_blob, :action,
    :value, :school_id, :district_id, :grade, :data_type_id,
    :source, :cohort_count, :proficiency_band_id, :configuration, :active,
    :academics, :breakdowns

  SCHEMA = {
      'type' => 'object',
      'required' => %w[value state data_type_id active source],
      'properties' => {
          'state' => {'type' => 'string'},
          'data_type_id' => {'type' => 'integer'},
          'school_id' => {'type' => ['string', nil]},
          'district_id' => {'type' => ['string', nil]},
          'cohort_count' => {'type' => 'string'},
          'active' => {'type' => 'integer'},
          'grade' => {'type' => 'string'},
          'value' => {'type' => 'string'},
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
    @update_blob = update_blob || {}
    set_up_attr_accessors
    validate
  end

  def validate
    JSON::Validator.validate!(SCHEMA, @update_blob)
    # raise 'Every gsdata update must have have a state specified' if state.blank?
  end

  def source_replace_into_and_return_object
    Gsdata::Source
      .from_hash(source)
      .replace_into_and_return_object
  end

  def set_up_attr_accessors
    @update_blob.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def state_db
    state.downcase.to_sym
  end

  def create
    insert_data_value
  end

  def data_value
    @_data_value ||= DataValue.from_hash(
      'value' => value,
      'state' => state,
      'school_id' => school.try(:id),
      'district_id' => school_id ? nil : district.try(:id),
      'configuration' => configuration,
      'data_type_id' => data_type_id,
      'proficiency_band_id' => proficiency_band_id,
      'cohort_count' => cohort_count,
      'grade' => grade,
      'active' => active,
      'source' => source_replace_into_and_return_object,
      'data_values_to_breakdowns' => data_values_to_breakdowns,
      'data_values_to_academics' => data_values_to_academics
    )
  end

  def insert_data_value
    begin
      data_value.save!
    rescue StandardError => e
      raise
      GSLogger.error(:gsdata_load, nil, message: 'gsdata DataValue failed to save ' + e.message, vars: {
          value: value,
          state: state,
          school_id: school_id,
          district_id: district_id,
          data_type_id: data_type_id,
          proficiency_band_id: proficiency_band_id,
          cohort_count: cohort_count,
          grade: grade,
          active: active
      })
    end
  end

  def school
    @_school ||= School.on_db(state_db).find_by(state_id: school_id)
  end

  def district
    @_district ||= District.on_db(state_db).find_by(state_id: district_id)
  end
  
  def data_values_to_academics
    Array.wrap(academics).map do |academic|
      DataValuesToAcademic.new.tap do |dvta|
        dvta.academic_id = academic['id']
      end
    end
  end

  def data_values_to_breakdowns
    Array.wrap(breakdowns).map do |breakdown|
      DataValuesToBreakdown.new.tap do |dvtb|
        dvtb.breakdown_id = breakdown['id']
      end
    end
  end

end

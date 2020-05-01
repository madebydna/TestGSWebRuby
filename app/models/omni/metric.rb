module Omni
  class Metric < ActiveRecord::Base
    db_magic connection: :omni

    STATE_ENTITY = 'state'
    DISTRICT_ENTITY = 'district'
    SCHOOL_ENTITY = 'school'

    belongs_to :breakdown
    belongs_to :subject
    belongs_to :data_set

    scope :state_entity, -> { where(entity_type: STATE_ENTITY) }
    scope :district_entity, -> { where(entity_type: DISTRICT_ENTITY) }
    scope :school_entity, -> { where(entity_type: SCHOOL_ENTITY) }
    scope :active, -> { where(active: 1) }

    def self.for_school(school)
      school_entity.joins(:data_set)
      .where(gs_id: school.id, data_sets: { state: school.state })
    end

    def self.for_district(district)
      district_entity.joins(:data_set)
      .where(gs_id: district.id, data_sets: { state: district.state })
    end

    # State represents an instance of Omni::State
    def self.for_state(state)
      state_entity.joins(:data_set)
      .where(gs_id: state.id, data_sets: { state: state.abbreviation })
    end

    def self.filter_by_data_types(data_type_ids)
      joins(data_set: :data_type)
      .where(data_types: { id: data_type_ids })
    end

    def self.include_entity_average(type:, id:, table_alias: 'm2')
      select("#{table_alias}.value as #{type}_value").
        joins("LEFT JOIN metrics #{table_alias} ON #{table_alias}.entity_type = '#{type}'
        AND #{table_alias}.gs_id = #{id}
        AND metrics.data_set_id = #{table_alias}.data_set_id
        AND metrics.breakdown_id = #{table_alias}.breakdown_id
        AND metrics.subject_id = #{table_alias}.subject_id
        AND metrics.grade = #{table_alias}.grade")
    end

  end
end
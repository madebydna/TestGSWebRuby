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

    def self.include_entity_average(type:, id:, table_alias_num: 2)
      metrics_table_alias = "m#{table_alias_num}"
      select("#{metrics_table_alias}.value as #{type}_value").
        joins("LEFT JOIN data_sets ds2 on ds2.state = data_sets.state
          AND ds2.date_valid = data_sets.date_valid
          AND ds2.source_id = data_sets.source_id
          AND ds2.data_type_id = data_sets.data_type_id")
        .joins("LEFT JOIN metrics #{metrics_table_alias} ON #{metrics_table_alias}.data_set_id = ds2.id
          AND #{metrics_table_alias}.entity_type = '#{type}'
          AND #{metrics_table_alias}.gs_id = #{id}
          AND metrics.breakdown_id = #{metrics_table_alias}.breakdown_id
          AND metrics.subject_id = #{metrics_table_alias}.subject_id
          AND metrics.grade = #{metrics_table_alias}.grade")
    end

  end
end
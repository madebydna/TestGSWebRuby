# frozen_string_literal: true

module Omni
  class TestDataValue < ActiveRecord::Base
    db_magic connection: :omni

    STATE_ENTITY = 'state'
    DISTRICT_ENTITY = 'district'
    SCHOOL_ENTITY = 'school'
    TAGS = %w(state_test)

    belongs_to :data_set
    belongs_to :proficiency_band
    belongs_to :breakdown
    belongs_to :data_set

    scope :state_entity, -> { where(entity_type: STATE_ENTITY) }
    scope :district_entity, -> { where(entity_type: DISTRICT_ENTITY) }
    scope :school_entity, -> { where(entity_type: SCHOOL_ENTITY) }
    scope :active, -> { where(active: 1) }
    scope :default_proficiency, -> { where(proficiency_band_id: 1) }

    def self.all_by_school(state, id)
      common_all_query(state).school_entity.where(gs_id: id)
    end

    def self.all_by_district(state, id)
      common_all_query(state).district_entity.where(gs_id: id)
    end

    def self.all_by_state(state)
      common_all_query(state).state_entity
    end

    def self.feeds_by_school(state, school_id)
      common_feeds_query(state).school_entity.where(gs_id: school_id)
    end

    def self.feeds_by_district(state, district_id)
      common_feeds_query(state).district_entity.where(gs_id: district_id)
    end

    def self.feeds_by_state(state)
      common_feeds_query(state).state_entity
    end

    def self.common_all_query(state)
      common_query.merge(DataSet.by_state(state)).default_proficiency
    end

    def self.common_feeds_query(state)
      common_query.merge(DataSet.feeds_by_state(state))
    end

    def self.common_query
      select(required_keys_db_mapping.values)
          .joins(data_set: [:data_type, :source])
          .joins(:proficiency_band)
          .with_data_type_tags
          .with_breakdowns
          .with_breakdown_tags
          .with_subjects
          .with_subject_tags
          .joins(:proficiency_band)
          .where(data_type_tags: { tag: TAGS })
          .active
    end

    def self.with_data_type_tags
      joins("join data_type_tags on data_type_tags.data_type_id = data_types.id")
    end

    def self.with_breakdowns
      joins("left join breakdowns on breakdown_id = breakdowns.id")
    end

    def self.with_breakdown_tags
      joins("left join breakdown_tags on breakdown_tags.breakdown_id = breakdowns.id")
    end

    def self.with_subjects
      joins("left join subjects on subjects.id = subject_id")
    end

    def self.with_subject_tags
      joins("left join subject_tags on subjects.id = subject_tags.subject_id")
    end

    def self.datatype_breakdown_year(obj)
      [obj.data_type_id, obj.breakdown_names, obj.date_valid, obj.academic_names, obj.grade]
    end

    def self.required_keys_db_mapping
      {
          value: "value",
          grade: "grade",
          cohort_count: "cohort_count",
          proficiency_band_id: "proficiency_band_id",
          proficiency_band_name: "proficiency_bands.name as proficiency_band_name",
          school_id: "gs_id as school_id",
          data_type_id: "data_types.id as data_type_id",
          name: "data_types.name",
          state: "data_sets.state",
          configuration: "data_sets.configuration",
          date_valid: "data_sets.date_valid",
          description: "data_sets.description",
          source: "sources.name as source",
          source_name: "sources.name as source_name",
          breakdown_tags: "breakdown_tags.tag as breakdown_tags",
          breakdown_names: "breakdowns.name as breakdown_names",
          breakdown_id_list: "breakdowns.id as breakdown_id_list",
          academic_names: "subjects.name as academic_names",
          academic_tags: "subject_tags.tag as academic_tags",
      }
    end
  end
end
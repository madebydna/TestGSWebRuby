# frozen_string_literal: true

require 'ruby-prof'

module Omni
  class Rating < ActiveRecord::Base
    db_magic connection: :omni

    belongs_to :data_set

    STATE_ENTITY = 'state'
    DISTRICT_ENTITY = 'district'
    SCHOOL_ENTITY = 'school'

    scope :state_entity, -> { where(entity_type: STATE_ENTITY) }
    scope :district_entity, -> { where(entity_type: DISTRICT_ENTITY) }
    scope :school_entity, -> { where(entity_type: SCHOOL_ENTITY) }
    scope :active, -> { where(active: 1) }

    def self.by_school(state, id)
      select(self.key_to_db.values)
          .joins(data_set: [:data_type, :source])
          .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
          .where(data_type_tags: { tag: %w(rating summary_rating_weight) })
          .with_breakdowns
          .with_breakdown_tags
          .merge(DataSet.by_state(state))
          .where(gs_id: id)
          .school_entity
          .active
    end

    def self.key_to_db
      {
          value: "value",
          state: "data_sets.state",
          school_id: "gs_id as school_id",
          data_type_id: "data_sets.data_type_id",
          configuration: "data_sets.configuration",
          source: "sources.name",
          source_name: "sources.name",
          date_valid: "data_sets.date_valid",
          description: "data_sets.description",
          name: "data_types.name",
          breakdown_tags: "breakdown_tags.tag",
          breakdown_names: "breakdowns.name"
      }
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

  end
end
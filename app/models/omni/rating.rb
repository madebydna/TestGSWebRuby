# frozen_string_literal: true

require 'ruby-prof'

module Omni
  class Rating < ActiveRecord::Base
    db_magic connection: :omni

    belongs_to :data_set

    STATE_ENTITY = 'state'
    DISTRICT_ENTITY = 'district'
    SCHOOL_ENTITY = 'school'
    TAGS = %w(rating summary_rating_weight)

    scope :state_entity, -> { where(entity_type: STATE_ENTITY) }
    scope :district_entity, -> { where(entity_type: DISTRICT_ENTITY) }
    scope :school_entity, -> { where(entity_type: SCHOOL_ENTITY) }
    scope :active, -> { where(active: 1) }

    def self.by_school(state, id)
      select(self.required_keys_db_mapping.values)
          .joins(data_set: [:data_type, :source])
          .with_data_type_tags
          .with_breakdowns
          .with_breakdown_tags
          .merge(DataSet.none_or_web_by_state(state))
          .where(data_type_tags: { tag: TAGS })
          .where(gs_id: id)
          .school_entity
          .active
    end

    def self.required_keys_db_mapping
      {
          value: "value",
          state: "data_sets.state",
          school_id: "gs_id as school_id",
          data_type_id: "data_sets.data_type_id",
          configuration: "data_sets.configuration",
          source: "sources.name as source",
          source_name: "sources.name as source_name",
          date_valid: "data_sets.date_valid",
          description: "data_sets.description",
          name: "data_types.name",
          breakdown_tags: "breakdown_tags.tag as breakdown_tags",
          breakdown_names: "breakdowns.name as breakdown_names"
      }
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

  end
end
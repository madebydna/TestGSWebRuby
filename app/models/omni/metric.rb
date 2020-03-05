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
      district_entity.where(gs_id: district.id)
    end

    # State represents an instance of Omni::State
    def self.for_state(state)
      state_entity.where(gs_id: state.id)
    end

  end
end
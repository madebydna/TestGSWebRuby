# frozen_string_literal: true

require 'ruby-prof'

class Rating < ActiveRecord::Base

  DATA_TYPE_IDS = %w(151 155 156 157 158 159 160 175 176 177 178 179 180 181 182 183 184 185 186 187).freeze

  db_magic connection: :omni

  belongs_to :data_set

  scope :state_entity, -> { where(entity_type: 'state') }
  scope :district_entity, -> { where(entity_type: 'district') }
  scope :school_entity, -> { where(entity_type: 'school') }
  scope :active, -> { where(active: 1) }
  scope :default_proficiency, -> { where(proficiency_band_id: 1) }

  def self.by_school(state, id)
    select(
        :value,
        "data_sets.state",
        "gs_id as school_id",
        :active,
        "data_sets.data_type_id",
        "data_sets.configuration",
        "sources.name as source",
        "sources.name as source_name",
        "data_sets.date_valid",
        "data_sets.description",
        "data_types.name",
        "breakdown_tags.tag as breakdown_tags",
        "breakdowns.name as breakdown_names"
    )
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .with_breakdown_tags
        .with_subjects
        .with_subject_tags
        .where(data_type_tag: { tag: %w(rating summary_rating_weight) })
        .where(data_set: { data_type_id: DATA_TYPE_IDS.join(",") })
        .merge(DataSet.by_state(state))
        .where(gs_id: id)
        .school_entity
        .active
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

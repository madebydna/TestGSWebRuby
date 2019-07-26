# frozen_string_literal: true

require 'ruby-prof'

class TestDataValue < ActiveRecord::Base
  self.table_name = 'test_data_values'

  db_magic connection: :omni

  belongs_to :data_set
  belongs_to :proficiency_band
  belongs_to :breakdown

  has_many :data_sets

  scope :state_entity, -> { where(entity_type: 'state') }
  scope :district_entity, -> { where(entity_type: 'district') }
  scope :school_entity, -> { where(entity_type: 'school') }
  scope :active, -> { where(active: 1) }
  scope :default_proficiency, -> { where(proficiency_band_id: 1) }

  def self.web_by_school(state, id)
    select(common_attrs).common_web_query(state).school_entity.where(gs_id: id).default_proficiency
  end

  def self.web_by_district(state, id)
    select(common_attrs).common_web_query(state).district_entity.where(gs_id: id).default_proficiency
  end

  def self.web_by_state(state)
    select(common_attrs).common_web_query(state).state_entity.default_proficiency
  end

  def self.feeds_by_school(state, school_id)
    select(common_attrs).common_feeds_query(state).school_entity.where(gs_id: school_id)
  end

  def self.feeds_by_district(state, district_id)
    select(common_attrs).common_feeds_query(state).district_entity.where(gs_id: district_id)
  end

  def self.feeds_by_state(state)
    select(common_attrs).common_feeds_query(state).state_entity
  end

  def self.common_web_query(state)
    common_query.merge(DataSet.by_state(state))
  end

  def self.common_feeds_query(state)
    common_query.merge(DataSet.feeds_by_state(state))
  end

  def self.common_query
    joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .with_breakdown_tags
        .with_subjects
        .with_subject_tags
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
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

  def self.datatype_breakdown_year(obj)
    [obj.data_type_id, obj.breakdown_names, obj.date_valid, obj.academic_names, obj.grade]
  end

  def self.common_attrs
    [:value,
     :grade,
     :cohort_count,
     :proficiency_band_id,
     :gs_id,
     "data_types.name",
     "sources.name as source_name",
     "sources.name as source",
     "proficiency_bands.name as proficiency_band_name",
     "breakdowns.name as breakdown_names",
     "breakdowns.id as breakdown_id_list",
     "subjects.name as academic_names",
     "data_sets.state",
     "data_sets.data_type_id",
     "data_sets.configuration",
     "data_sets.date_valid",
     "data_sets.description"]
  end

end
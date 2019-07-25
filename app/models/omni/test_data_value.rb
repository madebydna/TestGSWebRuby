# frozen_string_literal: true

require 'ruby-prof'

class TestDataValue < ActiveRecord::Base
  self.table_name = 'test_data_values'

  db_magic connection: :omni

  belongs_to :data_set
  belongs_to :proficiency_band
  belongs_to :breakdown

  has_many :data_sets

  ENTITIES = %w(nation state district school).freeze

  scope :state_entity, -> { where(entity_type: 'state') }
  scope :district_entity, -> { where(entity_type: 'district') }
  scope :school_entity, -> { where(entity_type: 'school') }
  scope :active, -> { where(active: 1) }

  #todo validate date format for date valid

  def self.web_by_school(school_state, school_id)
    # where ds.state = '#{school_state}'
    #   and entity_type = 'school'
    #   and gs_id = #{school_id}
    # and dtt.tag = 'state_test'
    # and tdv.active = 1
    # and proficiency_band_id = 1
    select(common_cache_keys)
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .with_subjects
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
        .merge(DataSet.by_state(state))
        .district_entity
        .active
        .where(gs_id: district_id)
  end

  def self.web_by_district(state, district_id)
    # where ds.state = '#{state}'
    #   and entity_type = 'district'
    #   and gs_id = #{district_id}
    # and dtt.tag = 'state_test'
    # and tdv.active = 1
    # AND proficiency_band_id = 1
    select(common_cache_keys)
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .joins("left join subjects on subjects.id = subject_id")
        .joins("left join subject_tags on subjects.id = subject_tags.subject_id")
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
        .merge(DataSet.by_state(state))
        .district_entity
        .active
        .where(gs_id: district_id)
  end

  def self.web_by_state(state)
    # where ds.state = '#{state}'
    #   and entity_type = 'state'
    # and dtt.tag = 'state_test'
    # and tdv.active = 1
    # AND proficiency_band_id = 1

    select(common_cache_keys)
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .joins("left join subjects on subjects.id = subject_id")
        .joins("left join subject_tags on subjects.id = subject_tags.subject_id")
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
        .merge(DataSet.by_state(state))
        .district_entity
        .active
        .where(gs_id: district_id)
  end

  def self.feeds_by_school(school_state, school_id)
    # where ds.state = '#{school_state}'
    #   and entity_type = 'school'
    #   and gs_id = #{school_id}
    #   and ds.configuration like '%feeds%'
    #   and dtt.tag = 'state_test'
    #   and tdv.active = 1
    select(common_cache_keys)
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .joins("left join subjects on subjects.id = subject_id")
        .joins("left join subject_tags on subjects.id = subject_tags.subject_id")
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
        .merge(DataSet.by_state(state))
        .district_entity
        .active
        .where(gs_id: district_id)
  end

  def self.feeds_by_district(state, district_id)
    select(common_cache_keys)
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .joins("left join subjects on subjects.id = subject_id")
        .joins("left join subject_tags on subjects.id = subject_tags.subject_id")
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
        .merge(DataSet.by_state(state))
        .district_entity
        .active
        .where(gs_id: district_id)
  end

  def self.feeds_by_state(state)
    select(common_cache_keys)
        .joins(data_set: [:data_type, :source])
        .joins("join data_type_tags on data_type_tags.data_type_id = data_sets.data_type_id")
        .with_breakdowns
        .with_subjects
        .joins(:proficiency_band)
        .where(data_type_tags: { tag: 'state_test' })
        .merge(DataSet.feeds_by_state(state))
        .state_entity
        .active
  end

  def self.with_breakdowns
    joins("left join breakdowns on breakdown_id = breakdowns.id")
        .joins("left join breakdown_tags on breakdown_tags.breakdown_id = breakdowns.id")
  end

  def self.with_subjects
    joins("left join subjects on subjects.id = subject_id")
        .joins("left join subject_tags on subjects.id = subject_tags.subject_id")
  end

  def self.common_cache_keys
    [:value,
     :grade,
     :cohort_count,
     :proficiency_band_id,
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
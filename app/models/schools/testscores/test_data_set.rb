class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  include StateSharding
  include LookupDataPreloading

  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :level_code, :proficiency_band_id, :school_decile_tops, :subject_id, :year

  has_many :test_data_school_values, class_name: 'TestDataSchoolValue', foreign_key: 'data_set_id'
  has_many :test_data_state_values, class_name: 'TestDataStateValue', foreign_key: 'data_set_id'
  belongs_to :test_data_type, :class_name => 'TestDataType', foreign_key: 'data_type_id'

  delegate :value_text, :modified, :modified_by,
           to: :test_data_school_value, prefix: 'school', allow_nil: true
  delegate :value_float, :modified, :modified_by,
           to: :test_data_school_value, prefix: 'school', allow_nil: true

  preload_all :test_data_type, :as => :test_data_type, :foreign_key => :data_type_id

  def display_name
    test_data_type.display_name
  end

  def test_data_school_value
    test_data_school_values[0] if test_data_school_values.any?
  end

  def self.fetch_test_scores(school, data_set_conditions = {})
    self.base_performance_query(school)
      .where(data_set_conditions)
      .with_display_targets('desktop')
  end

  scope :with_display_targets, ->(*display_targets) {
    where_statements = display_targets.map do |target|
      "display_target like '%#{target}%'"
    end
    where(where_statements.join(' OR '))
  }

  scope :with_no_subject_breakdowns, -> { where(subject_id: 1) }

  scope :active, -> { where(active: 1) }

  def self.ratings_for_school school
    TestDataSet.on_db(school.shard)
    .active
    .includes(:test_data_school_values)
    .where('TestDataSchoolValue.school_id = ? and TestDataSchoolValue.active = ?', school.id, 1).references(:test_data_school_values)
    .with_display_targets('ratings')
    .with_no_subject_breakdowns
  end

  def self.base_performance_query(school)
    TestDataSet.on_db(school.shard)
      .select("*,TestDataSet.id as data_set_id,
      TestDataStateValue.value_float as state_value_float,
      TestDataStateValue.value_text as state_value_text,
      TestDataSchoolValue.value_float as school_value_float,
      TestDataSchoolValue.value_text as school_value_text,
      TestDataSchoolValue.number_tested as number_students_tested,
      TestDataSet.proficiency_band_id as proficiency_band_id,
      TestDataStateValue.number_tested as state_number_tested ")
      .joins("LEFT OUTER JOIN TestDataSchoolValue on TestDataSchoolValue.data_set_id = TestDataSet.id")
      .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id and TestDataStateValue.active = 1")
      .where(TestDataSchoolValue: { school_id: school.id, active: 1 })
      .active
  end

  def self.fetch_performance_results(school, data_set_conditions = {})
    self.base_performance_query(school)
      .where(data_set_conditions)
      .with_display_targets('desktop', 'ratings')
  end

end

class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  include StateSharding
  include LookupDataPreloading

  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :level_code, :proficiency_band_id, :school_decile_tops, :subject_id, :year

  has_many :test_data_school_values, class_name: 'TestDataSchoolValue', foreign_key: 'data_set_id'
  has_many :test_data_state_values, class_name: 'TestDataStateValue', foreign_key: 'data_set_id'
  has_many :test_data_district_values, class_name: 'TestDataDistrictValue', foreign_key: 'data_set_id'
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

  def self.fetch_feed_test_scores(school, data_set_conditions = {})
    self.base_performance_school_feed_query(school)
        .where(data_set_conditions)
        .with_display_targets('feed')
  end

  def self.fetch_feed_test_scores_district(district)
    self.base_performance_district_feed_query(district)
    .with_display_targets('feed')
  end

  scope :with_display_targets, ->(*display_targets) {
    where_statements = display_targets.map do |target|
      "display_target like '%#{target}%'"
    end
    where(where_statements.join(' OR '))
  }

  # rubocop:disable Style/FormatStringToken
  scope :latest_active_feed_data_set, -> {
    where(:active => 1).
    where('display_target LIKE :display_target', display_target: '%feed%')
  }
  # rubocop:enable Style/FormatStringToken

  scope :with_data_type, ->(data_type) { where(data_type_id: data_type.id) }
  scope :with_no_subject_breakdowns, -> { where(subject_id: 1) }
  scope :all_students, -> { where(breakdown_id: 1) }

  scope :active, -> { where(active: 1) }

  def self.ratings_config_for_state(state,data_type_id)
    TestDataSet.on_db(state.downcase.to_sym)
    .where('data_type_id =?',data_type_id)
    .active
    .with_display_targets('ratings')
    .with_no_subject_breakdowns
    .all_students
  end

  def self.ratings_for_school school
    TestDataSet.on_db(school.shard)
      .joins("INNER JOIN #{TestDataType.connection_config[:database]}.TestDataType tdt on tdt.id = TestDataSet.data_type_id")
    .active
    .includes(:test_data_school_values)
    .with_display_targets('ratings')
    .where('tdt.classification = ?', 'gs_rating')
    .where('TestDataSchoolValue.school_id = ? and TestDataSchoolValue.active = ?', school.id, 1).references(:test_data_school_values)
    .with_no_subject_breakdowns
  end

  def self.historic_ratings_for_school(school, data_type_ids, exclude_data_set_ids)
    TestDataSet.on_db(school.shard)
      .joins("INNER JOIN #{TestDataType.connection_config[:database]}.TestDataType tdt on tdt.id = TestDataSet.data_type_id")
    .active
    .includes(:test_data_school_values)
    .where('tdt.classification = ?', 'gs_rating')
    .where('TestDataSchoolValue.school_id = ? and TestDataSchoolValue.active = ?', school.id, 1).references(:test_data_school_values)
    .with_no_subject_breakdowns
    .where(data_type_id: Array.wrap(data_type_ids))
    .where.not(id: Array.wrap(exclude_data_set_ids))
    .all_students
  end

  def self.ratings_for_district district
    TestDataSet.on_db(district.shard)
    .active
    .includes(:test_data_district_values)
    .where('TestDataDistrictValue.district_id = ? and TestDataDistrictValue.active = ?', district.id, 1).references(:test_data_district_values)
    .with_display_targets('ratings')
    .with_no_subject_breakdowns
    .all_students
  end


  def self.test_scores_for_state(state)
    TestDataSet.on_db(state.downcase.to_sym)
    .select("TestDataSet.data_type_id as data_type_id,
             TestDataSet.year,
             TestDataSet.subject_id,
             TestDataSet.breakdown_id,
             TestDataSet.grade as grade_name,
             TestDataSet.level_code as level_code,
             TestDataSet.id as data_set_id,
             TestDataStateValue.value_float as state_value_float,
             TestDataStateValue.value_text as state_value_text,
             TestDataSet.proficiency_band_id as proficiency_band_id,
             TestDataStateValue.number_tested as number_students_tested ")
            .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id")
            .joins("LEFT OUTER JOIN gs_schooldb.TestDataType on TestDataType.id = TestDataSet.data_type_id")
            .where('TestDataStateValue.active = ?',1).where(TestDataType: {classification:'state_test'})
            .active
            .all_students
            .with_display_targets('feed')
  end

  def self.test_scores_subgroup_for_state(state)
    TestDataSet.on_db(state.downcase.to_sym)
        .select("TestDataSet.data_type_id as data_type_id,
             TestDataSet.year,
             TestDataSet.subject_id,
             TestDataSet.breakdown_id,
             TestDataSet.grade as grade_name,
             TestDataSet.level_code as level_code,
             TestDataSet.id as data_set_id,
             TestDataStateValue.value_float as state_value_float,
             TestDataStateValue.value_text as state_value_text,
             TestDataSet.proficiency_band_id as proficiency_band_id,
             TestDataStateValue.number_tested as number_students_tested ")
            .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id")
            .joins("LEFT OUTER JOIN gs_schooldb.TestDataType on TestDataType.id = TestDataSet.data_type_id")
            .where('TestDataStateValue.active = ?',1).where(TestDataType: {classification:'state_test'})
            .active
            .with_display_targets('feed')
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

  def self.base_performance_school_feed_query(school)
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
        .joins("LEFT OUTER JOIN gs_schooldb.TestDataType on TestDataType.id = TestDataSet.data_type_id")
        .where(TestDataSchoolValue: { school_id: school.id, active: 1 })
        .where(TestDataType: {classification:'state_test'})
        .active
  end


  def self.base_performance_district_feed_query(district)
    TestDataSet.on_db(district.shard)
        .select("*,TestDataSet.id as data_set_id,
      TestDataStateValue.value_float as state_value_float,
      TestDataStateValue.value_text as state_value_text,
      TestDataDistrictValue.value_float as school_value_float,
      TestDataDistrictValue.value_text as school_value_text,
      TestDataDistrictValue.number_tested as number_students_tested,
      TestDataSet.proficiency_band_id as proficiency_band_id,
      TestDataStateValue.number_tested as state_number_tested ")
        .joins("LEFT OUTER JOIN TestDataDistrictValue on TestDataDistrictValue.data_set_id = TestDataSet.id")
        .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id and TestDataStateValue.active = 1")
        .joins("LEFT OUTER JOIN gs_schooldb.TestDataType on TestDataType.id = TestDataSet.data_type_id")
        .where(TestDataDistrictValue: {district_id: district.id, active: 1})
        .where(TestDataType: {classification: 'state_test'})
        .active
  end

  def self.fetch_performance_results(school, data_set_conditions = {})
    self.base_performance_query(school)
      .where(data_set_conditions)
      .with_display_targets('desktop', 'ratings')
  end

end

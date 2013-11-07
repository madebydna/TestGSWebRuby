class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  include StateSharding
  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :level_code, :proficiency_band_id, :school_decile_tops, :subject_id, :year

  has_many :test_data_school_values, class_name: 'TestDataSchoolValue', foreign_key: 'data_set_id'
  has_many :test_data_state_values, class_name: 'TestDataStateValue', foreign_key: 'data_set_id'
  belongs_to :test_data_type, :class_name => 'TestDataType', foreign_key: 'data_type_id'

  def self.fetch_data_sets_and_values(school_id, breakdown_id, active)
    TestDataSet.select("*,TestDataStateValue.value_float as state_val_float, TestDataStateValue.value_text as state_val_text,
                          TestDataSchoolValue.value_float as school_val_float, TestDataSchoolValue.value_text as school_val_text ")
                      .joins("LEFT OUTER JOIN TestDataSchoolValue on TestDataSchoolValue.data_set_id = TestDataSet.id")
                      .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id")
                      .where(proficiency_band_id: nil, breakdown_id: breakdown_id,
                             TestDataSchoolValue: {school_id: school_id, active: active},
                             TestDataStateValue: {active: active}).where("display_target like '%desktop%' ")
  end

  def self.fetch_test_scores(school)
    TestDataSet.fetch_data_sets_and_values(school, 1, 1)
  end

  def self.lookup_subject
    {
        1 => 'All subjects',
        2 => 'reading',
        3 => 'writing',
        4 => 'english language arts',
        5 => 'math',
        7 => 'algebra 1',
        8 => 'integrated math 1',
        9 => 'geometry',
        10 => 'integrated math 2',
        11 => 'algebra 2',
        12 => 'integrated math 3',
        19 => 'english',
        24 => 'social studies',
        25 => 'science',
        26 => 'foreign lang',
        27 => 'english 2',
        28 => 'algebra',
        29 => 'biology 1',
        30 => 'history',
        43 => 'earth science',
        13 => 'high school summative mathematics grade 9_11',
        53 => 'world history',
        42 => 'chemistry',
        41 => 'physics'

    }
  end




end

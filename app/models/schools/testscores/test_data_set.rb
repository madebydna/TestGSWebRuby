class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  include StateSharding
  include LookupDataPreloading

  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :proficiency_band_id, :school_decile_tops, :subject_id, :year

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

  def level_code_str
     read_attribute(:level_code)
  end

  def level_code
    LevelCode.new(level_code_str)
  end

  def self.fetch_data_sets_and_values(school, breakdown_id, active)
    TestDataSet.on_db(school.shard).select("*,TestDataSet.id as ds_id,TestDataStateValue.value_float as state_val_float, TestDataStateValue.value_text as state_val_text,
                          TestDataSchoolValue.value_float as school_val_float, TestDataSchoolValue.value_text as school_val_text")
                      .joins("LEFT OUTER JOIN TestDataSchoolValue on TestDataSchoolValue.data_set_id = TestDataSet.id")
                      .where(proficiency_band_id: nil, breakdown_id: breakdown_id,
                             TestDataSchoolValue: {school_id: school.id, active: active}).where("display_target like '%desktop%' ")
                      .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id and TestDataStateValue.active = 1")

  end

  def self.fetch_test_scores(school)

    cached_test_scores = SchoolCache.for_school('test_scores',school.id,school.state)

    begin
      results = cached_test_scores.blank? ? [] : JSON.parse(cached_test_scores.value)
    rescue JSON::ParserError => e
      results = []
      Rails.logger.debug "ERROR: parsing JSON test scores from school cache for school: #{school.id} in state: #{school.state}" +
                             "Exception message: #{e.message}"

    end

    # convert into a custom map to make rspec testing easier
    results_array = results.map do |result|
      {test_data_type_id: result['data_type_id'],
       test_data_set_id: result['ds_id'],
       grade: result['grade'],
       level_code: result['level_code'],
       subject_id: result['subject_id'],
       year: result['year'],
       school_value_text: result['school_val_text'],
       school_value_float: result['school_val_float'],
       state_value_text: result['state_val_text'],
       state_value_float: result['state_val_float'],
       breakdown_id: result['breakdown_id'],
       number_tested: result['number_tested']
      }
    end

    results_array
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


  scope :with_display_target, ->(display_target) {
    where('display_target like ?',"%#{display_target}%") }

  scope :with_no_subject_breakdowns, -> { where(subject_id: 1) }

  scope :active, -> { where(active: 1) }

  def self.ratings_for_school school
    TestDataSet.on_db(school.shard).active
    .includes(:test_data_school_values)
    .active
    .where('TestDataSchoolValue.school_id = ?', school.id)
    .with_display_target('ratings')
    .with_no_subject_breakdowns
  end

end

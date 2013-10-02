class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  octopus_establish_connection(:adapter => 'mysql2', :database => '_ca')
  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :level_code, :proficiency_band_id, :school_decile_tops, :subject_id, :year

  has_many :test_data_school_values, class_name: 'TestDataSchoolValue', foreign_key: 'data_set_id'

  def self.for_school(schoolId)

    #Todo. Is there a better way to do this? Maybe break up into multiple queries.
    TestDataSet.select("*").joins("LEFT OUTER JOIN TestDataSchoolValue on TestDataSchoolValue.data_set_id = TestDataSet.id")
                           .where(proficiency_band_id: nil, breakdown_id: 1,
                                  TestDataSchoolValue: {school_id: schoolId, active: 1} )
                           .where("display_target like '%desktop%' ")

  end

  def self.test_data_for_school(schoolId)
    @data_sets_and_values = TestDataSet.for_school(schoolId)
    @all_data_set_ids = @data_sets_and_values.pluck("TestDataSet.id")
    @valid_data_set_ids = TestDataSetFile.get_valid_data_set_ids(@all_data_set_ids)

    test_data = TestData.new
    @data_sets_and_values.each do |result|

      #Todo get the test data type, subject, grade, level code objects?
      #Todo query the testdatatype table for the tests
      #Todo consider a different data structure instead of nested maps.

      if @valid_data_set_ids.include?(result.data_set_id)
        test_data_type_id = result.data_type_id
        test_data_set_id = result.data_set_id
        grade = result.grade
        level_code = result.level_code
        subject = lookup_subject[result.subject_id]
        year = result.year
        test_score_float = result.value_float
        test_score_text = result.value_text
        breakdown_id = result.breakdown_id
        number_tested = result.number_tested

        test_data.deep_merge!({ "#{test_data_type_id}" => { "#{grade}" => { "#{level_code}" => { "#{subject}" => { "#{test_data_set_id}" => {"score" => test_score_float , "number_tested" => number_tested} }  }}}})

      end

      #my_hash = { :nested_hash => { :first_key => 'Hello' } }
      #Map<CustomTestDataType, Map<Grade, Map<LevelCode, Map<Subject, Map<CustomTestDataSet, Pair<String,Integer>>>>>> testScoresMap,
    end
    #ap test_data
    test_data
  end



  def self.lookup_subject
    {
        1 => 'All subjects',
        2 => 'reading',
        3 =>  'writing',
        4 =>  'english language arts',
        5 => 'math',
        7 => 'algebra1',
        8 => 'integrated math 1',
        9 => 'geometry',
        10 => 'integrated math 2',
        11 => 'algebra2',
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
        13 => 'HIGH_SCHOOL_SUMMATIVE_MATHEMATICS_GRADE_9_11',
        53 => 'WORLD_HISTORY',
        42 => 'CHEMISTRY',
        41 => 'PHYSICS'

    }
  end

  def self.lookup_test
    {
        18 => 'California Standards Tests',
        19 => 'California High School Exit Examination'
    }
  end

end

class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  octopus_establish_connection(:adapter => 'mysql2', :database => '_ca')
  attr_accessible :active, :breakdown_id, :data_type_id, :display_target, :grade, :level_code, :proficiency_band_id, :school_decile_tops, :subject_id, :year

  has_many :test_data_school_values, class_name: 'TestDataSchoolValue', foreign_key: 'data_set_id'
  has_many :test_data_state_values, class_name: 'TestDataStateValue', foreign_key: 'data_set_id'
  belongs_to :test_data_type, :class_name => 'TestDataType', foreign_key: 'data_type_id'

  def self.for_school(school_id,breakdown_id,active)

    #Todo. Is there a better way to do this? Maybe break up into multiple queries.
    TestDataSet.select("*,TestDataStateValue.value_float as state_val_float, TestDataStateValue.value_text as state_val_text,
                          TestDataSchoolValue.value_float as school_val_float, TestDataSchoolValue.value_text as school_val_text ")
                           .joins("LEFT OUTER JOIN TestDataSchoolValue on TestDataSchoolValue.data_set_id = TestDataSet.id")
                           .joins("LEFT OUTER JOIN TestDataStateValue on TestDataStateValue.data_set_id = TestDataSet.id")
                           .where(proficiency_band_id: nil, breakdown_id: breakdown_id,
                                  TestDataSchoolValue: {school_id: school_id, active: active},
                                  TestDataStateValue: {active: active})
                           .where("display_target like '%desktop%' ")

  end

  def self.fetch_test_scores(school)
    @data_sets_and_values = TestDataSet.for_school(school,1,1)
    @all_data_set_ids = @data_sets_and_values.pluck("TestDataSet.id")
    @valid_data_set_ids = TestDataSetFile.get_valid_data_set_ids(@all_data_set_ids,school)

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
        test_score = result.school_val_text.nil? ? result.school_val_float : result.school_val_text
        state_avg = result.state_val_text.nil? ? result.state_val_float : result.state_val_text
        breakdown_id = result.breakdown_id
        number_tested = result.number_tested

        #test_data.deep_merge!({ "#{test_data_type_id}" => { "#{grade}" => { "#{level_code}" => { "#{subject}" => { "#{year}" => {"score" => test_score_float , "number_tested" => number_tested} }  }}}})



        test_data.deep_merge!(
            {test_data_type_id =>
                 {
                     testLabel: 'a test label',
                     description: 'description',
                     grades: {
                         grade =>
                             {level_code =>
                                  {subject =>
                                       {year =>
                                            {
                                                "score" => test_score,
                                                "number_tested" => number_tested
                                            }
                                       }
                                  }
                             }
                     }
                 }
            }
        )
      end

      #my_hash = { :nested_hash => { :first_key => 'Hello' } }
      #Map<CustomTestDataType, Map<Grade, Map<LevelCode, Map<Subject, Map<CustomTestDataSet, Pair<String,Integer>>>>>> testScoresMap,
    end
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
        13 => 'high school summative mathematics grade 9_11',
        53 => 'world history',
        42 => 'chemistry',
        41 => 'physics'

    }
  end

  def self.lookup_test
    {
        18 => 'California Standards Tests',
        19 => 'California High School Exit Examination'
    }
  end

end

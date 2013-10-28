class TestDataSet < ActiveRecord::Base
  self.table_name = 'TestDataSet'
  include StateSharding
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
    test_meta_data = Hash.new
    test_data = Hash.new

    #TODO join this table as well?
    #Get the data set Ids that have a corresponding entry in TestDataSetFile. This table is in
    #gs_schooldb, hence could not join with the tables in state dbs.
    @valid_data_set_ids = TestDataSetFile.get_valid_data_set_ids(@all_data_set_ids,school)

    #test_data = TestData.new
    #test_meta_data = TestData.new

    @data_sets_and_values.each do |result|

      #Todo get the test data type, subject, grade, level code objects?

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

        if test_meta_data[test_data_type_id].nil?
          test_meta_data[test_data_type_id] = TestDataType.by_id(test_data_type_id)
        end

        #Check if the test is already in the map.
        if test_data[test_data_type_id].nil?
          #Test not present

          test_data[test_data_type_id] = {
              test_label: test_meta_data[test_data_type_id].display_name,
              test_description: test_meta_data[test_data_type_id].description,
              grades: {
                  grade =>
                      {level_code =>
                           {subject =>
                                {year =>
                                     {
                                         "score" => test_score,
                                         "number_tested" => number_tested,
                                         "state_avg" => state_avg
                                     }
                                }
                           }
                      }
              }
          }


        else
          #Test already present.
          data_type_id_to_data = test_data[test_data_type_id]

          #Check if grade is already in the map.
          if data_type_id_to_data[:grades].nil? || data_type_id_to_data[:grades][grade].nil?
            #Grade not present.

            grade_map =
                {level_code =>
                     {subject =>
                          {year =>
                               {
                                   "score" => test_score,
                                   "number_tested" => number_tested,
                                   "state_avg" => state_avg
                               }
                          }
                     }
                }

            if test_data[test_data_type_id][:grades].nil?
              test_data[test_data_type_id][:grades] = Hash.new
              test_data[test_data_type_id][:grades][grade] =grade_map
            elsif test_data[test_data_type_id][:grades][grade].nil?
              test_data[test_data_type_id][:grades][grade] =grade_map
            end


          else
            #Grade already present

            #Check if level code is already in the map
            if data_type_id_to_data[:grades][grade][level_code].nil?

              #Level code not present
              test_data[test_data_type_id][:grades][grade][level_code] =
                  {subject =>
                       {year =>
                            {
                                "score" => test_score,
                                "number_tested" => number_tested,
                                "state_avg" => state_avg
                            }
                       }
                  }

            else
              #Level code already present.

              #Check if subject is already in the map
              if test_data[test_data_type_id][:grades][grade][level_code][subject].nil?

                #Subject not present.
                test_data[test_data_type_id][:grades][grade][level_code][subject] = {year =>
                                                                                         {
                                                                                             "score" => test_score,
                                                                                             "number_tested" => number_tested,
                                                                                             "state_avg" => state_avg
                                                                                         }
                }

              else
                #Subject already present.

                #Check if year is already in the map
                if test_data[test_data_type_id][:grades][grade][level_code][subject][year].nil?
                  #year is not present.
                  test_data[test_data_type_id][:grades][grade][level_code][subject][year] =
                      {
                          "score" => test_score,
                          "number_tested" => number_tested,
                          "state_avg" => state_avg
                      }

                end
              end
            end
          end
        end


        ##Todo use Hashie or not?
        #unless test_meta_data.key?(test_data_type_id)
        #
        #  test_meta_data.deep_merge!({test_data_type_id => TestDataType.by_id(test_data_type_id)})
        #end

        #construct the Map of test ids to grades to level code to subject to year.
        #test_data.deep_merge!(
        #    {test_data_type_id =>
        #         {
        #             test_label: test_meta_data[test_data_type_id].display_name,
        #             test_description: test_meta_data[test_data_type_id].description,
        #             grades: {
        #                 grade =>
        #                     {level_code =>
        #                          {subject =>
        #                               {year =>
        #                                    {
        #                                        "score" => test_score,
        #                                        "number_tested" => number_tested,
        #                                        "state_avg" => state_avg
        #                                    }
        #                               }
        #                          }
        #                     }
        #             }
        #         }
        #    }
        #)
      end

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

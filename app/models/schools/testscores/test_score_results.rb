class TestScoreResults

  def fetch_test_data_sets_and_values(school)

    #Get all the test data sets and values for the school
    data_sets_and_values = TestDataSet.fetch_test_scores school

    #construct a list of all the data set ids for the school.
    all_data_set_ids =  []
    if !data_sets_and_values.blank?
      data_sets_and_values.each {|value| all_data_set_ids << value[:test_data_set_id] }
    end

    #Get the list of valid data set ids for the school based on the  school_type.
    valid_data_set_ids = all_data_set_ids.blank? ? [] : TestDataSetFile.get_valid_data_set_ids(all_data_set_ids, school)

    #Filter the data sets against the valid ones.
    data_sets_and_values.select!{|result| valid_data_set_ids.include?(result[:test_data_set_id])}

    data_sets_and_values
  end


  def fetch_test_scores(school)
    data_sets_and_values = fetch_test_data_sets_and_values school

    if !data_sets_and_values.blank?
      test_scores = build_test_scores_hash data_sets_and_values
      sort_test_scores test_scores
    end
  end


  def build_test_scores_hash(data_sets_and_values)
    test_meta_data = Hash.new
    test_scores = Hash.new

    data_sets_and_values.each do |result_hash|
      #Todo get the test data type, subject, grade, level code objects
      #TODO grade all

        test_data_type_id = result_hash[:test_data_type_id]
        test_data_set_id = result_hash[:test_data_set_id]
        grade = result_hash[:grade]
        level_code = result_hash[:level_code]
        subject = TestDataSet.lookup_subject[result_hash[:subject_id]]
        year = result_hash[:year]
        test_score = result_hash[:school_value_text].nil? ? result_hash[:school_value_float] : result_hash[:school_value_text]
        state_avg = result_hash[:state_value_text].nil? ? result_hash[:state_value_float] : result_hash[:state_value_text]
        breakdown_id = result_hash[:breakdown_id]
        number_tested = result_hash[:number_tested]


        if test_meta_data[test_data_type_id].nil?
          test_meta_data[test_data_type_id] = TestDataType.by_id(test_data_type_id)
        end

        #Check if the test is already in the map.
        if test_scores[test_data_type_id].nil?

          #Test not present
          test_scores[test_data_type_id] = {
              test_label: test_meta_data[test_data_type_id].display_name,
              test_description: test_meta_data[test_data_type_id].description,
              lowest_grade: grade,
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

          #Check if grade is already in the map.
          if test_scores[test_data_type_id][:grades].nil? || test_scores[test_data_type_id][:grades][grade].nil?

            #Grade not present.

            if (test_scores[test_data_type_id][:lowest_grade]).to_i > grade.to_i
              test_scores[test_data_type_id][:lowest_grade] = grade
            end


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

            if test_scores[test_data_type_id][:grades].nil?
              test_scores[test_data_type_id][:grades] = Hash.new
            end

            test_scores[test_data_type_id][:grades][grade] =grade_map

          else
            #Grade already present

            #Check if level code is already in the map
            if test_scores[test_data_type_id][:grades][grade][level_code].nil?

              #Level code not present
              test_scores[test_data_type_id][:grades][grade][level_code] =
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
              if test_scores[test_data_type_id][:grades][grade][level_code][subject].nil?

                #Subject not present.
                test_scores[test_data_type_id][:grades][grade][level_code][subject] =
                    {year =>
                         {
                             "score" => test_score,
                             "number_tested" => number_tested,
                             "state_avg" => state_avg
                         }
                    }

              else
                #Subject already present.

                #Check if year is already in the map
                if test_scores[test_data_type_id][:grades][grade][level_code][subject][year].nil?

                  #year is not present.
                  test_scores[test_data_type_id][:grades][grade][level_code][subject][year] =
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
    end

    test_scores
  end


  def sort_test_scores test_scores

    test_scores.each do |test_id, grades_hash|
      test_scores[test_id][:grades].each do |grade, level_codes_hash|
        level_codes_hash.each do |level_code, subjects_hash|
          subjects_hash.each do |subject, years_hash|
            years_hash.each do
              #Sort years
              test_scores[test_id][:grades][grade][level_code][subject] = Hash[years_hash.sort_by { |k, v| k.to_i }.reverse!]
            end
          end
          #Sort subjects
          test_scores[test_id][:grades][grade][level_code] = Hash[subjects_hash.sort_by { |k, v| k }]
        end
      end
      #sort grades
      test_scores[test_id][:grades] = grades_hash[:grades].sort_by { |k, v| k.to_i }
    end
    #Sort the tests by lowest grade in the test
    test_scores.sort_by { |k, v| v[:lowest_grade] }.reverse!
  end


end
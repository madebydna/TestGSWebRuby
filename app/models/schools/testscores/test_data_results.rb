class TestDataResults

  def fetch_results(school)
    data_sets_and_values = TestDataSet.fetch_test_scores school

    all_data_set_ids = data_sets_and_values.blank? ? [] : data_sets_and_values.pluck("TestDataSet.id")

    valid_data_set_ids = all_data_set_ids.blank? ? [] : TestDataSetFile.get_valid_data_set_ids(all_data_set_ids, school)

    if !data_sets_and_values.blank? && !valid_data_set_ids.blank?
      build_test_scores_hash data_sets_and_values, valid_data_set_ids
    end
  end

  def build_test_scores_hash(data_sets_and_values, valid_data_set_ids)
    test_meta_data = Hash.new
    test_data = Hash.new

    data_sets_and_values.each do |result|
      #Todo get the test data type, subject, grade, level code objects

      if valid_data_set_ids.include?(result.data_set_id)
        test_data_type_id = result.data_type_id
        test_data_set_id = result.data_set_id
        grade = result.grade
        level_code = result.level_code
        subject = TestDataSet.lookup_subject[result.subject_id]
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

          #Check if grade is already in the map.
          if test_data[test_data_type_id][:grades].nil? || test_data[test_data_type_id][:grades][grade].nil?

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
            end

            test_data[test_data_type_id][:grades][grade] =grade_map

          else
            #Grade already present

            #Check if level code is already in the map
            if test_data[test_data_type_id][:grades][grade][level_code].nil?

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
                test_data[test_data_type_id][:grades][grade][level_code][subject] =
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
      end
    end
    test_data
  end


end
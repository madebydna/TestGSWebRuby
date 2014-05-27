class TestScoreResults

  def fetch_test_scores(school)
    cached_test_scores = SchoolCache.for_school('test_scores',school.id,school.state)

    begin
      results = cached_test_scores.blank? ? [] : JSON.parse(cached_test_scores.value)
    rescue JSON::ParserError => e
      results = []
      Rails.logger.debug "ERROR: parsing JSON test scores from school cache for school: #{school.id} in state: #{school.state}" +
                           "Exception message: #{e.message}"
    end

    if results.present?
      test_scores = build_test_scores_hash(results,school)
      sort_test_scores(test_scores)
    else
      []
    end
  end

  def build_test_scores_hash(cached_results, school)
    #Hash to hold the results
    test_scores = Hash.new

    data_sets_and_values = cached_results['data_sets_and_values']
    data_type_descriptions = cached_results['data_types']

    if data_sets_and_values.present?
      data_sets_and_values.each do |result_hash|
        #TODO get the subject from the school cache.

        test_data_type_id = result_hash['data_type_id']
        test_data_set_id = result_hash['data_set_id']
        level_code = LevelCode.new(result_hash['level_code'])
        subject = TestDataSet.lookup_subject[result_hash['subject_id']]
        grade = Grade.from_string(result_hash['grade'])

        #If the grade = all then get the grade from the level_code. Do not show the level if the school does not have it.
        if !grade.name.nil? && grade.name == 'All'
          level_code.levels = level_code.levels.select {|level| school.includes_level_code?(level.abbreviation) }
          level_code.level_codes = level_code.level_codes.select {|level| school.includes_level_code?(level) }
          if !level_code.level_codes.blank?
            grade = Grade.from_level_code(level_code)
          end
        end

        grade_label = get_grade_label(grade,level_code)
        year = result_hash['year']
        test_score = result_hash['school_value_text'].nil? ? (result_hash['school_value_float']) : result_hash['school_value_text']
        test_score = test_score.round if(!test_score.nil? && test_score.is_a?(Float))
        state_avg = result_hash['state_value_text'].nil? ? result_hash['state_value_float'] : result_hash['state_value_text']
        state_avg = state_avg.round if(!state_avg.nil? && state_avg.is_a?(Float))
        breakdown_id = result_hash['breakdown_id']
        number_tested = result_hash['number_tested']
        if data_type_descriptions && data_type_descriptions[test_data_type_id.to_s].present?
          label = data_type_descriptions[test_data_type_id.to_s]['test_label']
          description = data_type_descriptions[test_data_type_id.to_s]['test_description'] || ''
          source = data_type_descriptions[test_data_type_id.to_s]['test_source'] || ''
        end

        next if subject.nil? # skip this test data if subject is nil

        #Check if the test is already in the map.
        if test_scores[test_data_type_id].nil?

          #Test not present
          test_scores[test_data_type_id] = {
              test_label: label,
              test_description: description,
              test_source: source,
              lowest_grade: grade.value,
              grades: {
                  grade =>
                      {label: grade_label,
                       level_code: {
                           level_code =>
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
          }
        else
          #Test already present.

          #Check if grade is already in the map.
          if test_scores[test_data_type_id][:grades].nil? || test_scores[test_data_type_id][:grades][grade].nil?

            #Grade not present.
            if (test_scores[test_data_type_id][:lowest_grade]).to_i > grade.value
              test_scores[test_data_type_id][:lowest_grade] = grade.value
            end


            grade_map =
                {label: grade_label,
                 level_code: {level_code =>
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

            if test_scores[test_data_type_id][:grades].nil?
              test_scores[test_data_type_id][:grades] = Hash.new
            end

            test_scores[test_data_type_id][:grades][grade] =grade_map

          else
            #Grade already present

            #Check if level code is already in the map
            if test_scores[test_data_type_id][:grades][grade][:level_code][level_code].nil?

              #Level code not present
              test_scores[test_data_type_id][:grades][grade][:level_code][level_code] =
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
              if test_scores[test_data_type_id][:grades][grade][:level_code][level_code][subject].nil?

                #Subject not present.
                test_scores[test_data_type_id][:grades][grade][:level_code][level_code][subject] =
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
                if test_scores[test_data_type_id][:grades][grade][:level_code][level_code][subject][year].nil?

                  #year is not present.
                  test_scores[test_data_type_id][:grades][grade][:level_code][level_code][subject][year] =
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
    test_scores
  end

  def sort_test_scores(test_scores)
    test_scores.each do |test_id, grades_hash|
      test_scores[test_id][:grades].each do |grade, level_codes_hash|
        level_codes_hash[:level_code].each do |level_code, subjects_hash|
          subjects_hash.each do |subject, years_hash|
            years_hash.each do
              #Sort years
              test_scores[test_id][:grades][grade][:level_code][level_code][subject] = Hash[years_hash.sort_by { |k, v| k.to_i }.reverse!]
            end
          end
          #Sort subjects
          test_scores[test_id][:grades][grade][:level_code][level_code] = Hash[subjects_hash.sort_by { |k, v| k }]
        end
      end
      #sort grades
      test_scores[test_id][:grades] = Hash[grades_hash[:grades].sort_by { |k, v| k.value }]
    end

    #Sort the tests by lowest grade in the test
    Hash[test_scores.sort_by { |k, v| v[:lowest_grade] }]
  end

  def get_grade_label(grade, level_code)
    grade_label = "GRADE " + grade.value.to_s
    if !grade.name.nil? && grade.name.start_with?('All')
      if level_code.levels.size >= 3
        grade_label = "All grades"
      else
        grade_label = level_code.levels.collect(&:long_name).join(" and ") + " school"
      end
    end
    grade_label
  end

end
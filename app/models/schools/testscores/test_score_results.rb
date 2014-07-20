class TestScoreResults

  def fetch_test_scores(school)
    cached_test_scores = SchoolCache.for_school('test_scores',school.id,school.state)

    begin
      results = cached_test_scores.blank? ? {} : JSON.parse(cached_test_scores.value, symbolize_names: true)
    rescue JSON::ParserError => e
      results = {}
      Rails.logger.debug "ERROR: parsing JSON test scores from school cache for school: #{school.id} in state: #{school.state}" +
                           "Exception message: #{e.message}"
    end

    data = {}
    if results.present?
      data = sort_test_scores(results) rescue {}
    end
    data
  end

  def sort_test_scores(test_scores)
    test_scores.each do |test_id, grades_hash|
      test_scores[test_id][:grades].each do |grade, level_codes_hash|
        level_codes_hash[:level_code].each do |level_code, subjects_hash|
          subjects_hash.each do |subject, years_hash|
            years_hash.each do
              #Sort years
              test_scores[test_id][:grades][grade][:level_code][level_code][subject] = Hash[years_hash.sort_by { |k, v| k.to_s.to_i }.reverse!]
            end
          end
          #Sort subjects
          test_scores[test_id][:grades][grade][:level_code][level_code] = Hash[subjects_hash.sort_by { |k, v| k }]
        end
      end
      #sort grades
      test_scores[test_id][:grades] = Hash[grades_hash[:grades].sort_by { |k, v| Grade.from_string(k.to_s).value }]
    end

    #Sort the tests by lowest grade in the test
    Hash[test_scores.sort_by { |k, v| v[:lowest_grade] }]
  end

end
class TestScoreResults

  def fetch_test_scores(school)
    cached_test_scores =  school.cache_results.test_scores

    begin
      results = cached_test_scores.blank? ? {} : cached_test_scores.deep_symbolize_keys
    rescue JSON::ParserError => e
      results = {}
      Rails.logger.debug "ERROR: parsing JSON test scores from school cache for school: #{school.id} in state: #{school.state}" +
                           "Exception message: #{e.message}"
    end

    data = {}
    if results.present?
      force_inclusion_of_breakdown(results)
      data = sort_test_scores(results)
    end
    data
  end

  def force_inclusion_of_breakdown(test_scores)
    test_scores.each do |test_id, hash|
      if hash.key?(:grades)
        test_scores[test_id] = {
          All: hash
        }
      end
    end
  end

  def sort_test_scores(test_scores)
    test_scores.each do |test_id, breakdown_hash|
      breakdown_hash.each do |breakdown, grades_hash|
        grades_hash[:grades].each do |grade, level_codes_hash|
          level_codes_hash[:level_code].each do |level_code, subjects_hash|
            subjects_hash.each do |subject, years_hash|
              years_hash.each do
                #Sort years
                test_scores[test_id][breakdown][:grades][grade][:level_code][level_code][subject] = Hash[years_hash.sort_by { |k, v| k.to_s.to_i }.reverse!]
              end
            end
            #Sort subjects
            test_scores[test_id][breakdown][:grades][grade][:level_code][level_code] = Hash[subjects_hash.sort_by { |k, v| k }]
          end
        end
        #sort grades
        test_scores[test_id][breakdown][:grades] = Hash[grades_hash[:grades].sort_by { |k, v| Grade.from_string(k.to_s).value }]
      end
    end
    # For tests with an "All" breakdown, sort by lowest grade
    # Move tests without "All" breakdown to end, maintain insertion order
    n = 12
    test_scores = Hash[
      test_scores.sort_by { |k, v| n += 1; v.seek(:All, :lowest_grade) || n }
    ]
  end

end
module CachedRatingsMethods

  NO_RATING_TEXT = 'NR'
  GREATSCHOOLS_RATINGS_NAMES = ['GreatSchools rating','Test score rating', 'Student growth rating', 'College readiness rating', 'Climate rating']
  HISTORICAL_RATINGS_KEYS = %w(year school_value_float)
  CSA_BADGE = 'CSA Badge'

  # 151: Advanced Course Rating
  # 155: Test Score Rating
  # 156: College Readiness Rating
  # 157: Student Progress Rating
  # 158: Equity Rating
  # 159: Academic Progress Rating
  # 160: Summary Rating

  def ratings
    cache_data['ratings'] || {}
  end

  def ratings_by_type
    @_ratings_by_type ||= (
      (cache_data['ratings'] || {}).each_with_object({}) do |(type, array), hash|
        hash[type] = GsdataCaching::GsDataValue.from_array_of_hashes(array)
      end
    )
  end

  # ignore nil criteria
  def ratings_matching_criteria(ratings, criteria)
    # if all criteria are contained within the rating (after removing nil
    # values) then we have a match
    ratings.select { |rating| (criteria.compact.to_a - rating.to_a).empty? }
  end

  def overall_gs_rating
    rating_for_key('Summary Rating')
  end

  def subratings
    formatted_ratings_table_view
    # result['Equity Overview Rating'] = result.delete('Equity rating') if result['Equity rating']
    # result.except!('GreatSchools rating')
    # result.except!('Student progress rating')
  end

  def ethnicity_information_for_tableview
    ethnicity_information.unshift(
      {}.tap do |i|
        i[:label] = "Low-income"
        i[:rating] = low_income_rating if low_income_rating
        i[:percentage] = free_and_reduced_lunch.gsub('%','')&.to_i if free_and_reduced_lunch
      end
    )
  end

  def ethnicity_breakdowns
    ethnicity_information_for_tableview
      .select {|breakdown| breakdown[:rating] && breakdown[:rating] > 0}
      .map {|filtered_breakdown| filtered_breakdown[:label]}
  end

   Breakdown.unique_ethnicity_names.each do |ethnicity|
    define_method("test_scores_rating_#{ethnicity.downcase.gsub(" ", "_")}") do
      send(:test_score_ratings_by_breakdown)[ethnicity]
    end
  end

  # Not using for now; will implement when we have better breakdown handling
  def translated_ethnicity_breakdowns_with_fallback
    ethnicity_breakdowns.map {|breakdown| I18n.t(breakdown, default: breakdown)}
  end

  def ethnicity_information
    ethnicity_labels.map do |label|
      {}.tap do |e|
        e[:label] = label
        e[:rating] = ethnicity_test_score_ratings["#{label}"] if ethnicity_test_score_ratings["#{label}"]
        e[:percentage] = ethnicity_population_percentages["#{label}"]&.to_i if ethnicity_population_percentages["#{label}"]
      end
    end
  end

  def ethnicity_struct_ratings
    ratings_by_type['Test Score Rating'].present? ? ratings_by_type['Test Score Rating'].having_breakdown_tags(['ethnicity', 'all_students']) : []
  end

  def ethnicity_test_score_ratings
    @_ethnicity_test_score_ratings ||= ethnicity_struct_ratings.each_with_object({}) do |struct, hash|
      hash[ethnicity_mapping_hash[struct.breakdown.to_sym]] = struct.school_value_as_int if struct.school_value_as_int && struct.school_value_as_int > 0
    end
  end

  def ethnicity_population_percentages
    @_percentages ||= ethnicity_data.each_with_object({}) do |data, hash|
      hash[ethnicity_mapping_hash[data["breakdown"].to_sym]] = data["school_value"].round if data["school_value"] && data["school_value"].round > 0
    end
  end

  def percentage_of_population_by_ethnicity(ethnicity)
    ethnicity_population_percentages[ethnicity]
  end

  def ethnicity_labels
    @_labels ||= (ethnicity_test_score_ratings.keys + ethnicity_population_percentages.keys).uniq
  end

  def ethnicity_mapping_hash
    {
      :'African American' => "African American",
      :'Black' => "African American",
      :'White' => "White",
      :'Asian or Pacific Islander' => "Asian or Pacific Islander",
      :'Asian' => asian_or_pacific?,
      :'All' => "All students",
      :'All students' => "All students",
      :'Multiracial' => "Two or more races",
      :'Two or more races' => "Two or more races",
      :'American Indian/Alaska Native' => "American Indian/Alaska Native",
      :'Native American' => "American Indian/Alaska Native",
      :'Pacific Islander' => "Pacific Islander",
      :'Hawaiian Native/Pacific Islander' => "Pacific Islander",
      :'Native Hawaiian or Other Pacific Islander' => "Pacific Islander",
      :'Economically disadvantaged' => "Low-income",
      :'Low Income' => "Low-income",
      :'Hispanic' => "Hispanic",
      :'Filipino' => "Filipino"
    }
  end

  # Special case handling for new york JT-9120
  # This silliness is because we don't know yet how we want to maintain consistency regarding ethnicity
  def asian_or_pacific?
    return "Asian" unless self.state == 'ny'
    "Asian or Pacific Islander"
  end

  def great_schools_rating
    test_score_rating_only? ? test_scores_rating : overall_gs_rating
  end

  def test_score_rating_only?
    overall_gs_rating.nil? && test_score_rating_weight == '1'
  end

  def great_schools_rating_year
    rating_year_for_key('Summary Rating')
  end

  def test_scores_rating
    rating_for_key('Test Score Rating')
  end

  def gsdata_test_scores_rating_hash
    rating_object_for_key('Test Score Rating')
  end

  def test_scores_rating_hash
    test_scores_rating_hash_map_to_old_format(rating_object_for_key('Test Score Rating'), 'Test Score Rating')
  end

  # Returns hash of breakdown to test score rating (int)
  # Using latest ratings
  def test_score_ratings_by_breakdown
    return {} unless ratings_by_type['Test Score Rating'].present?
    ratings_by_type['Test Score Rating']
      .having_most_recent_date
      .each_with_object({}) do |dv, ratings|
        ratings[dv.breakdown] = dv.school_value_as_int
      end
  end

  def test_scores_all_rating_hash
    test_scores_rating_hash_loop_through_and_update(ratings_by_type['Test Score Rating'], 'Test Score Rating')
  end

  def equity_overview_rating
    rating_for_key('Equity Rating')
  end

  def equity_overview_rating_hash
    rating_object_for_key('Equity Rating')
  end

  def equity_overview_rating_year
    rating_year_for_key('Equity Rating')
  end

  def courses_rating
    rating_for_key('Advanced Course Rating')
  end

  def courses_rating_hash
    rating_object_for_key('Advanced Course Rating')
  end

  def courses_rating_array
    course_subject_group = (ratings_by_type['Advanced Course Rating'] || []).select {|o| o.breakdown_tags == 'course_subject_group'}
    course_subject_group.each_with_object({}) do |dv, accum|
      if dv.breakdowns.present?
        subject = dv.breakdowns.downcase.gsub(' ', '_')
        accum[subject] = dv.school_value_as_int
      end
    end
  end

  def courses_academics_rating_array
    course_subject_group = ratings_by_type['Advanced Course Rating']
    Array.wrap(course_subject_group).each_with_object({}) do |dv, accum|
      if dv.academic.present?
        subject = dv.academic.downcase.gsub(' ', '_')
        accum[subject] = dv.school_value_as_int
      end
    end
  end

  def courses_rating_year
    rating_year_for_key('Advanced Course Rating')
  end

  def academic_progress_rating
    rating_for_key('Academic Progress Rating')
  end

  def academic_progress_rating_hash
    rating_object_for_key('Academic Progress Rating')
  end

  def academic_progress_rating_year
    rating_year_for_key('Academic Progress Rating')
  end

  def student_growth_rating
    rating_for_key('Student Progress Rating')
  end

  def student_progress_rating
    rating_for_key('Student Progress Rating')
  end

  def student_growth_rating_year
    rating_year_for_key('Student Progress Rating')
  end

  def student_growth_rating_hash
    rating_object_for_key('Student Progress Rating')
  end

  def college_readiness_rating_hash
    rating_object_for_key('College Readiness Rating')
  end

  def college_readiness_rating
    rating_for_key('College Readiness Rating')
  end

  def college_readiness_rating_year
    rating_year_for_key('College Readiness Rating')
  end

  def csa_award_winner_years
    return [] unless ratings_by_type[CSA_BADGE].present?

    ratings_by_type[CSA_BADGE]
      .map { |award| award[:source_year] }
  end

  def low_income_rating_hash
    rating_object_for_key('Test Score Rating', 'Economically disadvantaged')
  end

  def low_income_rating
    low_income_rating_hash.try(:school_value_as_int)
  end

  def low_income_rating_year
    low_income_rating_hash.try(:source_date_valid)
  end

  def discipline_flag_hash
    rating_object_for_key('Discipline Flag')
  end

  def absence_flag_hash
    rating_object_for_key('Absence Flag')
  end

  ####################################################################
  #
  # START - use with GSData
  #
  ####################################################################

  def rating_year_for_key(key)
    return nil unless ratings_by_type[key].present?

    ratings_by_type[key]
      .for_all_students
      .most_recent_source_year
  end

  def rating_for_key(key, breakdown = nil)
    rating_object_for_key(key, breakdown).try(:school_value_as_int)
  end

  # nil breakdown returns overall rating for key
  # returns ratings for most recent year
  def rating_object_for_key(key, breakdown = nil)
    return nil unless ratings_by_type[key].present?
    result = ratings_by_type[key].having_most_recent_date
    result = breakdown.nil? ? result.for_all_students.academic_breakdowns_blank : result.having_breakdown_in(breakdown)
    result.having_school_value.expect_only_one(
      'rating object for key',
      rating_type: key,
      breakdown: breakdown
    )
  end

  # return array of ratings hashes for key
  def rating_hashes_for_key(key)
    if ratings.present?
      ratings[key] || []
    else
      []
    end
  end

  def test_scores_rating_hash_loop_through_and_update(array, data_type)
    return [] if array.nil? || data_type.nil?
    array.map { | hash |  test_scores_rating_hash_map_to_old_format(hash, data_type) }
  end

  def test_scores_rating_hash_map_to_old_format(hash, data_type)
    return nil if hash.nil?
    h = {}
    h['school_value_float'] = hash.school_value.to_i
    h['year'] = hash.source_year.to_i
    h['test_data_type_display_name'] = data_type
    h['breakdown'] = hash.breakdown
    h['methodology'] = hash.methodology
    h['description'] = hash.description
    h
  end

  ####################################################################
  #
  # END - use with GSData
  #
  ####################################################################

  def formatted_non_greatschools_ratings
    formatted_ratings('other')
  end

  def formatted_greatschools_ratings
    formatted_ratings('gs_rating')
  end

  protected

  def all_great_schools_ratings
    ratings.select { |rating| GREATSCHOOLS_RATINGS_NAMES.include?(rating['name']) }
  end

  def non_great_schools_ratings
    ratings.select { |rating| !GREATSCHOOLS_RATINGS_NAMES.include?(rating['name']) }
  end

  # {"gs_rating"=>{174=>"GreatSchools rating", 164=>"Test score rating",
  # 165=>"Student progress rating", 166=>"College readiness rating",
  # 173=>"Climate rating"}}
  def formatted_ratings(rating_type=nil)
    if rating_type.nil? || rating_type == 'gs_rating'
      {
       :'GreatSchools rating' => :great_schools_rating,
       :'Test scores rating' => :test_scores_rating,
       :'Student progress rating' => :student_growth_rating,
       :'Academic progress rating' => :academic_progress_rating,
       :'College readiness rating' => :college_readiness_rating,
       :'Advanced courses rating' => :courses_rating,
       :'Equity rating' => :equity_overview_rating
      }.each_with_object({}) do |(name, method), accum|
        result = send(method)
        accum[name.to_s] = result if result
      end
    else
      {}
    end
  end

  def formatted_ratings_table_view(rating_type=nil)
    if rating_type.nil? || rating_type == 'gs_rating'
      {
          :'Test Scores Rating' => :test_scores_rating,
          :'Academic Progress Rating' => :academic_progress_rating,
          :'Student Progress Rating' => :student_growth_rating,
          :'College Readiness Rating' => :college_readiness_rating,
          :'Advanced Courses Rating' => :courses_rating,
          :'Equity Overview Rating' => :equity_overview_rating
      }.each_with_object({}) do |(name, method), accum|
        result = send(method)
        accum[name.to_s] = result if result
      end
    else
      {}
    end
  end

  def test_score_rating_weight
    cache_data.fetch('ratings', {}).fetch('Summary Rating Weight: Test Score Rating', []).first&.fetch('school_value',nil)
  end
end

module CachedRatingsMethods

  NO_RATING_TEXT = 'NR'
  GREATSCHOOLS_RATINGS_NAMES = ['GreatSchools rating','Test score rating', 'Student growth rating', 'College readiness rating', 'Climate rating']
  HISTORICAL_RATINGS_KEYS = %w(year school_value_float)

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

  # def ethnicity_information_for_tableview
  #   {
  #     ratings: ethnicity_ratings,
  #     students: ethnicity_students_for_tableview
  #   }
  # end

  def ethnicity_information
    ratings= ratings_by_type['Test Score Rating'].present? ? ratings_by_type['Test Score Rating'].having_exact_breakdown_tags('ethnicity') : []
    ethnicity_ratings = decorate_ethnicity_object(ratings,"rating")
    ethnicity_percentage = decorate_ethnicity_object(ethnicity_data,"percentage")
    ethnicity = []
    ethnicity_ratings.each do |rating_hash|
      ethnicity_percentage.each do |percentage_hash|
        if rating_hash[:label] == percentage_hash[:label]
          ethnicity << rating_hash.merge(percentage_hash)
        end
      end
    end    

    ethnicity
  end

  # def ethnicity_ratings
  #   fer = formatted_ethnicity_ratings
  #   fer = {'Low Income' => low_income_rating}.merge(fer) if fer && low_income_rating
  #   fer
  # end

  # def ethnicity_students_for_tableview
  #   fes = formatted_ethnicity_students
  #   fes = ({'Low Income': free_and_reduced_lunch.gsub('%','')}).merge(fes) if fes && free_and_reduced_lunch
  #   fes
  # end

  def great_schools_rating
    test_score_weight = (rating_weights.fetch('Summary Rating Weight: Test Score Rating', []).first || {})['school_value']
    if overall_gs_rating.nil? && test_score_weight == '1'
      test_scores_rating
    else
      overall_gs_rating
    end
  end

  def test_score_rating_only?
    rating_for_key('Summary Rating').nil? && (rating_weights.fetch('Summary Rating Weight: Test Score Rating', []).first || {})['school_value'] == '1'
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

  def formatted_ethnicity_ratings
    ethnicity = ratings_by_type['Test Score Rating'].present? ? ratings_by_type['Test Score Rating'].having_exact_breakdown_tags('ethnicity') : []
    ethnicity_population = 
      ethnicity.each_with_object({}) do |e, accum|
        accum[e.breakdowns.join(',')] = e.school_value  if e.school_value
      end
  end

  def formatted_ethnicity_students
    ethnicity_data.each_with_object({}) do |ethnicity_information_object, hash|
      if ethnicity_information_object["school_value"]
        attribute = ethnicity_mapping_hash[ethnicity_information_object["breakdown"].to_sym]
        hash[attribute] = ethnicity_information_object["school_value"].round
      end
    end
  end

  def decorate_ethnicity_object(array_of_hashes, key)
    ethnicity = array_of_hashes.map do |hash|
      if hash["school_value"]
        {
          label: ethnicity_mapping_hash[hash["breakdown"].to_sym],
          "#{key}": hash["school_value"].to_i
        }
      end
    end.compact

    case key
    when "rating"
      ethnicity.unshift({label: 'Low Income', "#{key}": low_income_rating.to_i}) if low_income_rating
    when "percentage"
      ethnicity.unshift({label: 'Low Income', "#{key}": free_and_reduced_lunch.gsub('%','').to_f}) if free_and_reduced_lunch
    end

    ethnicity
  end

  def ethnicity_mapping_hash
    {
      :'African American' => "African American",
      :'Black' => "African American",
      :'White' => "White",
      :'Asian or Pacific Islander' => "Asian or Pacific Islander",
      :'Asian' => "Asian",
      :'All' => "All students",
      :'Multiracial' => "Two or more races",
      :'Two or more races' => "Two or more races",
      :'American Indian/Alaska Native' => "American Indian/Alaska Native",
      :'Native American' => "American Indian/Alaska Native",
      :'Pacific Islander' => "Pacific Islander",
      :'Hawaiian Native/Pacific Islander' => "Pacific Islander",
      :'Native Hawaiian or Other Pacific Islander' => "Pacific Islander",
      :'Economically disadvantaged' => "Low-income",
      :'Low Income' => "Low-income",
      :'Hispanic' => "Hispanic"
    }
  end

  def rating_weights
    cache_data.fetch('gsdata', {}).select do |key, val|
      key.include?('Summary Rating Weight')
    end
  end
end

module SchoolProfiles
  class SchoolCacheDataReader
    # ratings - for gs rating
    # characteristics - for enrollment
    # reviews_snapshot - for review info in the profile hero
    # nearby_schools - for nearby schools module
    SCHOOL_CACHE_KEYS = %w(ratings characteristics reviews_snapshot test_scores nearby_schools performance gsdata esp_responses)

    attr_reader :school, :school_cache_keys

    def initialize(school, school_cache_keys: SCHOOL_CACHE_KEYS)
      self.school = school
      @school_cache_keys = school_cache_keys
    end

    def decorated_school
      @_decorated_school ||= decorate_school(school)
    end

    def cache_updated_dates
      decorated_school.cache_data.select { |k, _| k.match(/^_.*_updated$/) }.values.compact
    end

    def gs_rating
      ((1..10).to_a & [decorated_school.great_schools_rating]).first
    end

    def gs_rating_year
      decorated_school.great_schools_rating_year
    end

    def students_enrolled
      decorated_school.students_enrolled
    end

    def five_star_rating
      decorated_school.star_rating
    end

    def number_of_active_reviews
      decorated_school.num_reviews
    end

    def num_ratings
      decorated_school.num_ratings
    end

    def test_scores_rating
      decorated_school.test_scores_rating
    end

    def historical_test_scores_ratings
      decorated_school.historical_test_scores_ratings
    end

    def college_readiness_rating
      decorated_school.college_readiness_rating
    end

    def college_readiness_rating_year
      decorated_school.college_readiness_rating_year
    end

    def historical_college_readiness_ratings
      decorated_school.historical_college_readiness_ratings
    end

    def student_progress_rating
      decorated_school.student_growth_rating
    end

    def student_progress_rating_year
      decorated_school.student_growth_rating_year
    end

    def student_progress_rating_hash
      decorated_school.student_growth_rating_hash
    end

    def test_scores_rating_hash
      decorated_school.test_scores_rating_hash
    end

    def test_scores_all_rating_hash
      decorated_school.test_scores_all_rating_hash
    end

    def historical_student_progress_ratings
      decorated_school.historical_student_growth_ratings
    end

    def equity_ratings_breakdown(breakdown)
      if decorated_school.test_scores_all_rating_hash
        breakdown_results = decorated_school.test_scores_all_rating_hash.select { |bd|
          bd['breakdown'] == breakdown
        }
        if breakdown_results.is_a?(Array) && !breakdown_results.empty?
          breakdown_results.first['school_value_float']
        end
      end
    end

    def ethnicity_data
      decorated_school.ethnicity_data
    end

    def low_income_data
      decorated_school.free_or_reduced_price_lunch_data
    end

    def characteristics_data(*keys)
      decorated_school.characteristics.slice(*keys).each_with_object({}) do |(k,array_of_hashes), hash|
        array_of_hashes = array_of_hashes.select { |h| h.has_key?('source') }
        hash[k] = array_of_hashes if array_of_hashes.present?
      end
    end

    def nearby_schools
      decorated_school.nearby_schools
    end

    def test_scores
      decorated_school.test_scores
    end

    def flat_test_scores_for_latest_year
      output_array = []
      test_scores.values.each do |test_hash|
        test_hash.each do | breakdown_name, breakdown_hash|
          breakdown_hash['grades'].each { | grade |
            grade_value = grade.first
            level_code = grade.second['level_code']
            level_code.first[1].each do |subject, year_hash|
              max_year = year_hash.keys.max_by { |year| year.to_i }
              output_array << year_hash[max_year].merge(
                {
                  test_label: breakdown_hash['test_label'],
                  test_description: breakdown_hash['test_description'],
                  test_source: breakdown_hash['test_source'],
                  breakdown: breakdown_name,
                  year: max_year,
                  subject: subject,
                  grade: grade_value,
                  flags: year_hash[max_year]['flags']
                }
              ).symbolize_keys
            end if level_code
          }
        end
      end
      output_array
    end

    def graduation_rate_data
      decorated_school.characteristics['4-year high school graduation rate']
    end

    def characteristics
      decorated_school.characteristics
    end

    def gsdata_data(*keys)
      decorated_school.gsdata.slice(*keys).each_with_object({}) do |(k, values), new_hash|
        values = values.map do |h|
          h = h.clone
          if h['breakdowns']
            h['breakdowns'] = h['breakdowns'].gsub('All students except 504 category,','')
            h['breakdowns'] = h['breakdowns'].gsub(/,All students except 504 category$/,'')
          end
          h
        end
        new_hash[k] = values
      end
    end

    # Returns a hash that includes the percentage and sourcing info
    # {
    #   "breakdowns": "Students with disabilities",
    #   "breakdown_tags": "disability",
    #   "school_value": "11.59",
    #   "source_year": 2014,
    #   "source_name": "Civil Rights Data Collection"
    # }
    def percentage_of_students(breakdown)
      percentages = (
        decorated_school.gsdata.slice('Percentage of Students Enrolled') || {}
      ).fetch('Percentage of Students Enrolled', [])
      percentages.find { |h| h['breakdowns'] == breakdown }
    end

    def esp_responses_data(*keys)
      decorated_school.programs.slice(*keys)
    end

    def sources_with_subjects(breakdown: 'All', grades: 'All')
      @_sources_with_subjects ||= (

      )
    end

    def subject_scores_by_latest_year(breakdown: 'All', grades: 'All', level_codes: nil, subjects: nil)
      @_subject_scores_by_latest_year ||= (
        subject_hash = test_scores.map do |data_type_id, v|
          level_code_obj = v.seek(breakdown, 'grades', grades, 'level_code')
          if level_code_obj.present?
            level_code_obj.compact.each_with_object({}) do |input_hash, output_hash|
              input_hash[1].each do |subject, year_hash|
                latest_year = year_hash.keys.max_by { |year| year.to_i }
                next if year_hash[latest_year]['score'].nil?
                output_hash[subject] ||= {}
                val = test_scores[data_type_id.to_s][breakdown]
                year_hash[latest_year.to_s]['test_description'] = val['test_description']
                year_hash[latest_year.to_s]['test_label']       = val['test_label']
                year_hash[latest_year.to_s]['test_source']      = val['test_source']
                output_hash[subject]
                output_hash[subject].merge!(year_hash)
              end
              output_hash
            end
          end
        end

        subject_hash.compact!
        return [] unless subject_hash.present?
        subject_hash = subject_hash.compact.inject(:merge)
        subject_hash.select! { |subject, _| subjects.include?(subject) } if subjects.present?
        subject_hash.inject([]) do |scores_array, (subject, year_hash)|
          scores_array << OpenStruct.new({}.tap do |scores_hash|
            latest_year = year_hash.keys.max_by { |year| year.to_i }
            scores_hash.merge!(year_hash[latest_year.to_s])
            scores_hash['subject'] = subject
            scores_hash['year'] = latest_year
          end)
        end)
    end

    def school_cache_query
      SchoolCacheQuery.for_school(school).tap do |query|
        query.include_cache_keys(school_cache_keys)
      end
    end

    def decorate_school(school)
      query_results = school_cache_query.query
      school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
      school_cache_results.decorate_school(school)
    end

    private

    def school=(school)
      raise ArgumentError('School must be provided') if school.nil?
      @school = school
    end
  end
end

module MetricsCaching
  class StateMetricsCacher < StateCacher
    include StateCacheValidation

    CACHE_KEY = 'metrics'

    # 23: Percentage algebra 1 enrolled grades 7-8
    # 27: Percentage passing algebra 1 grades 7-8
    # 35: Percentage of students suspended out of school
    # 55: Percentage AP enrolled grades 9-12
    # 59: Percentage AP math enrolled grades 9-12
    # 63: Percentage AP science enrolled grades 9-12
    # 71: Percentage SAT/ACT participation grades 11-12
    # 83: Percentage of students passing 1 or more AP exams grades 9-12
    # 91: Percentage of students chronically absent (15+ days)
    # 95: Ratio of students to full time teachers
    # 99: Percentage of full time teachers who are certified
    # 119: Ratio of students to full time counselors
    # 133: Ratio of teacher salary to total number of teachers
    # 149: Percentage of teachers with less than three years experience
    # 152: Number of Advanced Courses Taken per Student
    # 154: Percentage of Students Enrolled
    # 365: Percentage of teachers in their first year
    # 366: Bachelor's degree
    # 367: Master's degree
    # 368: Doctorate's degree
    # 369: Students Per Teacher
    # 370: Students participating in free or reduced-price lunch program
    # 371: English learners
    # 372: Ethnicity
    # 373: Average years of teacher experience
    # 374: Students who are economically disadvantaged
    # 376: Enrollment
    # 378: Other degree
    # 380: Master's degree or higher
    # 381: Average years of teaching in district
    # 382: Teaching experience 0-3 years
    # 383: Percent classes taught by non-highly qualified teachers
    # 385: Head official name
    # 386: Head official email address
    # 396: ACT participation
    # 397: At least 5 years teaching experience
    # 398: Female
    # 399: Male
    # 401: Teachers with no valid license
    # 402: Percent classes taught by highly qualified teachers
    # 404: Teachers with valid license
    # 413: Percent Needing Remediation for College
    # 442: SAT percent college ready
    # 443: 4-year high school graduation rate
    # 448: Average ACT score
    # 454: ACT percent college ready
    # 462: Percent of Students Passing AP/IB Exams
    # 464: Percent of students who meet UC/CSU entrance requirements
    # 473: Percent enrolled in any public in-state postsecondary institution within 12 months after graduation
    # 474: Percent enrolled in any postsecondary institution within 12 months after graduation
    # 476: Percent enrolled in any 2 year postsecondary institution within 6 months after graduation
    # 475: Percent enrolled in any 2 year postsecondary institution within the immediate fall after graduation
    # 477: Percent enrolled in any 2 year public in-state postsecondary institution within the immediate fall after graduation
    # 478: Percent enrolled in any 4 year postsecondary institution within 6 months after graduation
    # 479: Percent enrolled in any 4 year postsecondary institution within the immediate fall after graduation
    # 480: Percent enrolled in any 4 year public in-state postsecondary institution within the immediate fall after graduation
    # 481: Percent enrolled in any in-state postsecondary institution within 12 months after graduation
    # 482: Percent enrolled in any in-state postsecondary institution within the immediate fall after graduation
    # 483: Percent enrolled in any out-of-state postsecondary institution within the immediate fall after graduation
    # 484: Percent enrolled in any postsecondary institution within 24 months after graduation
    # 485: Percent enrolled in any postsecondary institution within 6 months after graduation
    # 486: Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 18 months after graduation
    # 487: Percent enrolled in any public in-state postsecondary institution within the immediate fall after graduation
    # 488: Percent Enrolled in a public 4 year college and Returned for a Second Year
    # 489: Percent Enrolled in a public 2 year college and Returned for a Second Year

    DATA_TYPE_IDS_WHITELIST = [
      23,  27,  35,  55,  59,  63,  71,  83,  91,  95,  99,  119,
      133, 149, 152, 154, 365, 366, 367, 368, 369, 370, 371, 372,
      373, 374, 376, 378, 380, 381, 382, 383, 385, 386, 396, 397,
      398, 399, 401, 402, 404, 413, 442, 443, 448, 454, 462, 464,
      473, 474, 476, 475, 477, 478, 479, 480, 481, 482, 483, 484,
      485, 486, 487, 488, 489
    ]

    def self.listens_to?(data_type)
      data_type == :metrics
    end

    def query_results
      @_query_results ||= begin
        results = MetricsResults.new(MetricsStateQuery.new(state).call.to_a)
        results.filter_to_max_year_per_data_type!
      end
    end

    def build_hash_for_cache
      @_hash_for_cache ||= begin
        Hash.new {|h,k| h[k] = [] }.tap do |hash|
          query_results.each do |result|
            next if result.label.blank?
            hash[result.label] << build_hash_for_metric(result)
          end
        end
      end
      validate!(@_hash_for_cache)
    end

    def build_hash_for_metric(metric)
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:breakdown_tags] = metric.breakdown_tags
        hash[:state_value] = Float(metric.value) rescue metric.value
        hash[:grade] = metric.grade
        hash[:source] = metric.source_name
        hash[:source_date_valid] = metric.source_date_valid
        hash[:subject] = metric.subject_name
        hash[:year] = metric.year
      end
    end

  end
end
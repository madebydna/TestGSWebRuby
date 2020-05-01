module MetricsCaching
  class SchoolMetricsCacher < Cacher
    include CacheValidation
    CACHE_KEY = 'metrics'

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
    # 375: Special education
    # 376: Enrollment
    # 377: Students with disabilities
    # 378: Other degree
    # 379: Migrant
    # 380: Master's degree or higher
    # 381: Average years of teaching in district
    # 382: Teaching experience 0-3 years
    # 383: Percent classes taught by non-highly qualified teachers
    # 384: Dropout rate
    # 387: Parent education levels - not a high school graduate
    # 388: Parent education levels - high school graduate
    # 389: Parent education levels - some college
    # 390: Parent education levels - college graduate
    # 391: Parent education levels - graduate school
    # 392: Graduating seniors pursuing 4 year college/university
    # 393: Graduating seniors pursuing 2 year college/university
    # 394: Graduating seniors pursuing other college
    # 395: Graduating seniors pursuing military service
    # 396: ACT participation
    # 397: At least 5 years teaching experience
    # 398: Female
    # 399: Male
    # 400: Number classes taught by non-highly qualified teachers
    # 401: Teachers with no valid license
    # 402: Percent classes taught by highly qualified teachers
    # 403: Number classes taught by highly qualified teachers
    # 404: Teachers with valid license
    # 405: Not English learners
    # 406: Not special education
    # 407: Students who are not economically disadvantaged
    # 408: Total Full Time Equivalent Teachers
    # 409: Percent Enrolled in College and Returned for a Second Year
    # 410: Average Number of Units Completed in First Year of College
    # 411: Average GPA in First Year of College
    # 412: Percent Enrolled in College Immediately Following High School
    # 413: Percent Needing Remediation for College
    # 414: Percent enrolled in any institution of higher learning in the last 0-16 months
    # 415: Percent enrolled in any institution of higher learning in the last 0-24 months
    # 416: Percent enrolled in any institution of higher learning in the last 0-36 months
    # 417: Percent enrolled in any institution of higher learning in the last 0-48 months
    # 418: Percent accumulating 24 higher learning credits within 0-16 months
    # 419: Percent accumulating 24 higher learning credits within 0-24 months
    # 420: Percent accumulating 24 higher learning credits within 0-36 months
    # 421: Percent accumulating 24 higher learning credits within 0-48 months
    # 422: Percent enrolled in a 2-year institution of higher learning in the last 0-48 months
    # 423: Percent enrolled in a 2-year institution of higher learning in the last 0-36 months
    # 424: Percent enrolled in a 2-year institution of higher learning in the last 0-24 months
    # 425: Percent enrolled in a 2-year institution of higher learning in the last 0-16 months
    # 426: Percent enrolled in a 4-year institution of higher learning in the last 0-48 months
    # 427: Percent enrolled in a 4-year institution of higher learning in the last 0-36 months
    # 428: Percent enrolled in a 4-year institution of higher learning in the last 0-24 months
    # 429: Percent enrolled in a 4-year institution of higher learning in the last 0-16 months
    # 430: Percent Students in IDEA
    # 431: Percent Students in 504 Plan
    # 432: AP Course Participation
    # 433: AP Course Passed
    # 434: Alternative Program
    # 435: Gifted/talented Program
    # 436: Magnet School
    # 437: Special Education Focused
    # 438: ACT/SAT Number Participation
    # 439: SAT percent participation
    # 440: Has Counselor
    # 441: Percentage of teachers in their first/second year
    # 442: SAT percent college ready
    # 443: 4-year high school graduation rate
    # 444: Percent AP course passed
    # 445: Average PSAT score
    # 446: Average SAT score
    # 447: Student growth
    # 448: Average ACT score
    # 449: Percent of students who will attend out-of-state colleges
    # 450: Percent of students who will attend in-state colleges
    # 451: Percent of students who earned a GPA of at least 2.0 during their first year of college
    # 452: ACT/SAT percent participation
    # 453: ACT/SAT percent college ready
    # 454: ACT percent college ready
    # 455: Percentage of teachers with advanced degrees at school site
    # 456: Average years experience for teachers at school site
    # 457: Percentage of teachers with advanced degrees in district
    # 458: Michigan Growth, Total Improvement
    # 459: 5-year high school graduation rate
    # 460: Percentage of students meeting growth target
    # 461: Percent of Students Passing an AP or IB Test
    # 462: Percent of Students Passing AP/IB Exams
    # 463: Percent of Students Participating in AP/IB Exams
    # 464: Percent of students who meet UC/CSU entrance requirements
    # 465: Expulsion
    # 466: Suspension
    # 467: Truancy
    # 468: Parent education levels - declined to state
    # 469: Student Growth - MA MCAS
    # 470: Student Growth - MA PARCC
    # 471: Student Growth - CO CMAS
    # 472: Student Growth - CO PSAT/SAT
    # 473: Percent enrolled in any public in-state postsecondary institution within 12 months after graduation
    # 474: Percent enrolled in any postsecondary institution within 12 months after graduation
    # 475: Percent enrolled in any 2 year postsecondary institution within the immediate fall after graduation
    # 476: Percent enrolled in any 2 year postsecondary institution within 6 months after graduation
    # 477: Percent enrolled in any 2 year public in-state postsecondary institution within the immediate fall after graduation
    # 478: Percent enrolled in any 4 year postsecondary institution within 6 months after graduation
    # 479: Percent enrolled in any 4 year postsecondary institution within the immediate fall after graduation
    # 480: Percent enrolled in any 4 year public in-state postsecondary institution within the immediate fall after graduation
    # 481: Percent enrolled in any in-state postsecondary institution within 12 months after graduation
    # 482: Percent enrolled in any in-state postsecondary institution within the immediate fall after graduation
    # 483: Percent enrolled in any out-of-state postsecondary institution within the immediate fall after graduation
    # 484: Percent enrolled in any postsecondary institution within 24 months after graduation
    # 485: Percent enrolled in any postsecondary institution within 6 months after graduation
    # 487: Percent enrolled in any public in-state postsecondary institution within the immediate fall after graduation
    # 488: Percent Enrolled in a public 4 year college and Returned for a Second Year
    # 489: Percent Enrolled in a public 2 year college and Returned for a Second Year
    # 486: Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 18 months after graduation
    # 385: Head official name
    # 386: Head official email address
    # 493: Student Growth - Elementary Level
    # 494: Student Growth - Middle Level

    DATA_TYPE_IDS_WHITELIST = [
      365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376,
      377, 378, 379, 380, 381, 382, 383, 384, 387, 388, 389, 390,
      391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402,
      403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414,
      415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426,
      427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438,
      439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450,
      451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462,
      463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474,
      475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 487,
      488, 489, 486, 385, 386, 493, 494
    ]

    def self.listens_to?(data_type)
      data_type == :metrics
    end

    def query_results
      results = MetricsResults.new(MetricsSchoolQuery.new(school).call.to_a)
      results.filter_to_max_year_per_data_type!
      results.sort_school_value_desc_by_data_type!
    end

    def build_hash_for_cache
      @_build_hash_for_cache ||= begin
        hash = {}
        query_results.each do |result|
          hash[result.label] = [] unless hash.key? result.label
          hash[result.label] << build_hash_for_metric(result)
        end
        validate!(hash)
      end
    end

    # See gs_schooldb.census_data_type
    def build_hash_for_metric(metric)
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:school_value] = Float(metric.value) rescue metric.value
        if metric.district_value
          hash[:district_average] = Float(metric.district_value) rescue metric.district_value
        end
        if metric.state_value
          hash[:state_average] = Float(metric.state_value) rescue metric.state_value
        end
        hash[:grade] = metric.grade
        hash[:source] = metric.source_name
        hash[:subject] = metric.subject_name
        hash[:year] = metric.year
        hash[:created] = metric.created
      end
    end

  end
end
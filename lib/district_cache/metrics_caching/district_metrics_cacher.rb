module MetricsCaching
  class DistrictMetricsCacher < DistrictCacher
    include DistrictCacheValidation

    CACHE_KEY = 'metrics'

    # Note: original whitelist had 445 and 446 which don't appear
    # to be valid data_type_ids, i.e. they are missing from
    # gs_schooldb.census_data_type)
    # 23: Percentage algebra 1 enrolled grades 7-8
    # 27: Percentage passing algebra 1 grades 7-8
    # 35: Percentage of students suspended out of school
    # 51: Percentage of students enrolled in IB grades 9-12
    # 55: Percentage AP enrolled grades 9-12
    # 59: Percentage AP math enrolled grades 9-12
    # 63: Percentage AP science enrolled grades 9-12
    # 67: Percentage AP other courses enrolled grades 9-12
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
    # 320: Percentage of students enrolled in Dual Enrollment classes grade 9-12
    # 321: Percent of students enrolled in Algebra 1
    # 322: Percent of students passing Algebra 1
    # 335: Percent of Law Enforcement Staff
    # 336: Percent of Security Guard Staff
    # 337: Percent of Nurse Staff
    # 338: Percent of Psychologist Staff
    # 339: Percent of Social Worker Staff
    # 342: Total Revenue
    # 346: Total Expenditures
    # 351: Per Pupil Revenue
    # 352: Per Pupil Expenditures
    # 353: Percent Federal Revenue
    # 354: Percent State Revenue
    # 355: Percent Local Revenue
    # 356: Percent Instructional Expenditures
    # 357: Percent Support Services Expenditures
    # 358: Percent Other Expenditures
    # 359: Percent Uncategorized Expenditures
    # 370: Students participating in free or reduced-price lunch program
    # 371: English learners
    # 372: Ethnicity
    # 376: Enrollment
    # 392: Graduating seniors pursuing 4 year college/university
    # 393: Graduating seniors pursuing 2 year college/university
    # 394: Graduating seniors pursuing other college
    # 396: ACT participation
    # 398: Female
    # 399: Male
    # 412: Percent Enrolled in College Immediately Following High School
    # 413: Percent Needing Remediation for College
    # 409: Percent Enrolled in College and Returned for a Second Year
    # 414: Percent enrolled in any institution of higher learning in the last 0-16 months
    # 425: Percent enrolled in a 2-year institution of higher learning in the last 0-16 months
    # 429: Percent enrolled in a 4-year institution of higher learning in the last 0-16 months
    # 442: SAT percent college ready
    # 443: 4-year high school graduation rate
    # 448: Average ACT score
    # 449: Percent of students who will attend out-of-state colleges
    # 450: Percent of students who will attend in-state colleges
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
      23,  27,  35,  51,  55,  59,  63,  67,  71,  83,  91,  95,
      99,  119, 133, 149, 152, 154, 320, 321, 322, 335, 336, 337,
      338, 339, 342, 346, 351, 352, 353, 354, 355, 356, 357, 358,
      359, 370, 371, 372, 376, 392, 393, 394, 396, 398, 399, 412,
      413, 409, 414, 425, 429, 442, 443, 448, 449, 450, 454, 462,
      464, 473, 474, 476, 475, 477, 478, 479, 480, 481, 482, 483,
      484, 485, 486, 487, 488, 489
    ]

    def self.listens_to?(data_type)
      data_type == :metrics
    end

    def query_results
      @_query_results ||= begin
        results = MetricsResults.new(MetricsDistrictQuery.new(district).call.to_a)
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

    # NOTE: original district_characteristics hash had subject_id
    # but it doesn't appear to be used
    def build_hash_for_metric(metric)
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:breakdown_tags] = metric.breakdown_tags
        hash[:district_value] = Float(metric.value) rescue metric.value
        if metric.state_value
          hash[:state_average] = Float(metric.state_value) rescue metric.state_value
        end
        hash[:grade] = metric.grade
        hash[:source] = metric.source_name
        hash[:subject] = metric.subject_name
        hash[:year] = metric.year
        hash[:source_date_valid] = metric.source_date_valid
        #TODO: double check if this is used
        hash[:created] = metric.created
      end
    end

  end
end
module MetricsCaching::CollegeReadinessConfig

  DATA_CUTOFF_YEAR = 2015
# Constants for college readiness pane
  FOUR_YEAR_GRADE_RATE = '4-year high school graduation rate'
  UC_CSU_ENTRANCE = 'Percent of students who meet UC/CSU entrance requirements'
  SAT_SCORE = 'Average SAT score'
  SAT_PARTICIPATION = 'SAT percent participation'
  SAT_PERCENT_COLLEGE_READY = 'SAT percent college ready'
  ACT_SCORE = 'Average ACT score'
  ACT_PARTICIPATION = 'ACT participation'
  ACT_PERCENT_COLLEGE_READY = 'ACT percent college ready'
  AP_ENROLLED = 'Percentage AP enrolled grades 9-12'
  AP_EXAMS_PASSED = 'Percentage of students passing 1 or more AP exams grades 9-12'
  ACT_SAT_PARTICIPATION = 'Percentage SAT/ACT participation grades 11-12'
  ACT_SAT_PARTICIPATION_9_12 = 'Percent of Students who Participated in the SAT/ACT in grades 9-12'
  NEW_SAT_STATES = %w(ca ct mi nj co ma il)
  NEW_SAT_YEAR = 2016
  NEW_SAT_RANGE = (400..1600)
  OLD_SAT_RANGE = (600..2400)
  GRADUATES_REMEDIATION = 'Percent Needing Remediation for College'
  GRADUATES_PERSISTENCE = 'Percent Enrolled in College and Returned for a Second Year'
  IB_ENROLLMENT = 'Percentage of students enrolled in IB grades 9-12'
  DUAL_ENROLLMENT = 'Percentage of students enrolled in Dual Enrollment classes grade 9-12'

# Constants for college success pane
# Order matters - items display in configured order
  POST_SECONDARY = [
    'Graduating seniors pursuing other college',
    'Graduating seniors pursuing 4 year college/university',
    'Graduating seniors pursuing 2 year college/university',
    'Percent of students who will attend out-of-state colleges',
    'Percent of students who will attend in-state colleges',
    'Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 18 months after graduation',
    'Percent enrolled in any public in-state postsecondary institution within the immediate fall after graduation',
    'Percent Enrolled in College Immediately Following High School',
    'Percent enrolled in any institution of higher learning in the last 0-16 months',
    'Percent enrolled in a 4-year institution of higher learning in the last 0-16 months',
    'Percent enrolled in a 2-year institution of higher learning in the last 0-16 months',
    'Percent enrolled in any public in-state postsecondary institution within 12 months after graduation',
    'Percent enrolled in any postsecondary institution within 12 months after graduation',
    'Percent enrolled in any 4 year postsecondary institution within 6 months after graduation',
    'Percent enrolled in any 4 year postsecondary institution within the immediate fall after graduation',
    'Percent enrolled in any 4 year public in-state postsecondary institution within the immediate fall after graduation',
    'Percent enrolled in any 2 year postsecondary institution within 6 months after graduation',
    'Percent enrolled in any 2 year postsecondary institution within the immediate fall after graduation',
    'Percent enrolled in any 2 year public in-state postsecondary institution within the immediate fall after graduation',
    'Percent enrolled in any in-state postsecondary institution within 12 months after graduation',
    'Percent enrolled in any in-state postsecondary institution within the immediate fall after graduation',
    'Percent enrolled in any out-of-state postsecondary institution within the immediate fall after graduation',
    'Percent enrolled in any postsecondary institution within 24 months after graduation',
    'Percent enrolled in any postsecondary institution within 6 months after graduation'
  ]

  REMEDIATION_SUBGROUPS = [ GRADUATES_REMEDIATION,
                           'Graduates needing Reading remediation in college',
                           'Graduates needing Writing remediation in college',
                           'Graduates needing English remediation in college',
                           'Graduates needing Science remediation in college',
                           'Graduates needing Math remediation in college']
  SECOND_YEAR = [ GRADUATES_PERSISTENCE,
                 'Percent Enrolled in a public 4 year college and Returned for a Second Year',
                 'Percent Enrolled in a public 2 year college and Returned for a Second Year']



  POST_SECONDARY_GROUP_MAX_YEAR_FILTER = POST_SECONDARY

  FORMATTING_ROUND_LESS_THAN_ONE_PERCENT = %i(round_unless_less_than_1 percent)

# metrics cache accessors for college success pane
# at the end of this constant we add on the remediation subgroups, which are currently set to be displayed as person_gray
  CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS =
    POST_SECONDARY.map do |data_key|
      {
          :cache => :metrics,
          :data_key => data_key,
          :visualization => 'person',
          :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
      }
    end.concat(
      REMEDIATION_SUBGROUPS.map do |data_key|
        {
          :cache => :metrics,
          :data_key => data_key,
          :visualization => 'person_gray',
          :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
        }
      end
    ).concat(
      SECOND_YEAR.map do |data_key|
        {
            :cache => :metrics,
            :data_key => data_key,
            :visualization => 'person',
            :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
        }
      end
    )

# metrics cache accessors for college readiness pane
  CHAR_CACHE_ACCESSORS = [
    {
      :cache => :metrics,
      :data_key => FOUR_YEAR_GRADE_RATE,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :metrics,
      :data_key => UC_CSU_ENTRANCE,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :metrics,
      :data_key => SAT_SCORE,
      :visualization => 'bar',
      :formatting => [:round],
      :range => OLD_SAT_RANGE
    },
    {
      :cache => :metrics,
      :data_key => SAT_PARTICIPATION,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :metrics,
      :data_key => SAT_PERCENT_COLLEGE_READY,
      :visualization => 'bar',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :metrics,
      :data_key => ACT_SCORE,
      :visualization => 'bar',
      :formatting => [:round],
      :range => (1..36)
    },
    {
      :cache => :metrics,
      :data_key => ACT_PARTICIPATION,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :metrics,
      :data_key => ACT_PERCENT_COLLEGE_READY,
      :visualization => 'bar',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :gsdata,
      :data_key => AP_ENROLLED,
      :visualization => 'person',
      :formatting => [:to_f, :round_unless_less_than_1, :percent]
    },
    {
      :cache => :gsdata,
      :data_key => AP_EXAMS_PASSED,
      :visualization => 'bar',
      :formatting => [:to_f, :round_unless_less_than_1, :percent]
    },
    {
      :cache => :gsdata,
      :data_key => DUAL_ENROLLMENT,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :gsdata,
      :data_key => IB_ENROLLMENT,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :gsdata,
      :data_key => ACT_SAT_PARTICIPATION,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    },
    {
      :cache => :gsdata,
      :data_key => ACT_SAT_PARTICIPATION_9_12,
      :visualization => 'person',
      :formatting => FORMATTING_ROUND_LESS_THAN_ONE_PERCENT
    }
  ].freeze
end




module CommunityProfiles::CollegeReadinessConfig

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
# Constants for college success pane
  SENIORS_FOUR_YEAR = 'Graduating seniors pursuing 4 year college/university'
  SENIORS_TWO_YEAR = 'Graduating seniors pursuing 2 year college/university'
  SENIORS_ENROLLED_OTHER = 'Graduating seniors pursuing other college'
  SENIORS_ENROLLED = 'Percent Enrolled in College Immediately Following High School'
  GRADUATES_REMEDIATION = 'Percent Needing Remediation for College'
  GRADUATES_PERSISTENCE = 'Percent Enrolled in College and Returned for a Second Year'
  GRADUATES_COLLEGE_VOCATIONAL = 'Percent enrolled in any institution of higher learning in the last 0-16 months'
  GRADUATES_TWO_YEAR = 'Percent enrolled in a 2-year institution of higher learning in the last 0-16 months'
  GRADUATES_FOUR_YEAR = 'Percent enrolled in a 4-year institution of higher learning in the last 0-16 months'
  GRADUATES_OUT_OF_STATE = 'Percent of students who will attend out-of-state colleges'
  GRADUATES_IN_STATE = 'Percent of students who will attend in-state colleges'
  REMEDIATION_SUBGROUPS = ['Graduates needing Reading remediation in college',
                           'Graduates needing Writing remediation in college',
                           'Graduates needing English remediation in college',
                           'Graduates needing Science remediation in college',
                           'Graduates needing Math remediation in college']
# Order matters - items display in configured order

# characteristics cache accessors for college success pane
# at the end of this constant we add on the remediation subgroups, which are currently set to be displayed as person_gray
  CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS = [
    {
      :cache => :district_characteristics,
      :data_key => SENIORS_ENROLLED,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_COLLEGE_VOCATIONAL,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => SENIORS_FOUR_YEAR,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => SENIORS_TWO_YEAR,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => SENIORS_ENROLLED_OTHER,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_TWO_YEAR,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_FOUR_YEAR,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_OUT_OF_STATE,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_IN_STATE,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_REMEDIATION,
      :visualization => 'person_gray',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :characteristics,
      :data_key => GRADUATES_PERSISTENCE,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    }
  ].concat(
    REMEDIATION_SUBGROUPS.map do |data_key|
      {
        :cache => :characteristics,
        :data_key => data_key,
        :visualization => 'person_gray',
        :formatting => [:round_unless_less_than_1, :percent]
      }
    end
  )

# characteristics cache accessors for college readiness pane
  CHAR_CACHE_ACCESSORS = [
    {
      :cache => :district_characteristics,
      :data_key => FOUR_YEAR_GRADE_RATE,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => UC_CSU_ENTRANCE,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => SAT_SCORE,
      :visualization => 'bar',
      :formatting => [:round],
      :range => (600..2400)
    },
    {
      :cache => :district_characteristics,
      :data_key => SAT_PARTICIPATION,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => SAT_PERCENT_COLLEGE_READY,
      :visualization => 'bar',
      :formatting => %i(round_unless_less_than_1 percent)
    },
    {
      :cache => :district_characteristics,
      :data_key => ACT_SCORE,
      :visualization => 'bar',
      :formatting => [:round],
      :range => (1..36)
    },
    {
      :cache => :district_characteristics,
      :data_key => ACT_PARTICIPATION,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => ACT_PERCENT_COLLEGE_READY,
      :visualization => 'bar',
      :formatting => %i(round_unless_less_than_1 percent)
    },
    {
      :cache => :district_characteristics,
      :data_key => AP_ENROLLED,
      :visualization => 'person',
      :formatting => [:to_f, :round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => AP_EXAMS_PASSED,
      :visualization => 'bar',
      :formatting => [:to_f, :round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => ACT_SAT_PARTICIPATION,
      :visualization => 'person',
      :formatting => [:round_unless_less_than_1, :percent]
    },
    {
      :cache => :district_characteristics,
      :data_key => ACT_SAT_PARTICIPATION_9_12,
      :visualization => 'person',
      :formatting => %i(round_unless_less_than_1 percent)
    }
  ].freeze
end




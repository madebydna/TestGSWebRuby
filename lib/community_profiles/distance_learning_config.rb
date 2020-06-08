module CommunityProfiles::DistanceLearningConfig
  # Data Types
  URL = 'URL'
  SUMMARY = "SUMMARY"
  SUMMER_FALL_PLANNING = "SUMMER FALL PLANNING"
  RESOURCES_PROVIDED_BY_THE_DISTRICT = "RESOURCES PROVIDED BY THE DISTRICT"
  RESOURCE_COVERAGE = "RESOURCE COVERAGE"
  INSTRUCTION_FROM_TEACHERS = "INSTRUCTION FROM TEACHERS"
  SYNCHRONOUS_TEACHING_FLAG = "SYNCHRONOUS TEACHING FLAG"
  SYNCHRONOUS_STUDENT_ENGAGEMENT_FLAG = "SYNCHRONOUS STUDENT ENGAGEMENT FLAG"
  RESOURCES_FOR_STUDENTS_WITH_DISABILITIES = "RESOURCES FOR STUDENTS WITH DISABILITIES"
  FEEDBACK_ON_STUDENT_WORK = "FEEDBACK ON STUDENT WORK"
  FORMAL_GRADING_FLAG = "FORMAL GRADING FLAG"
  TEACHER_CHECK_INS = "TEACHER CHECK-INS"
  ATTENDANCE_TRACKING = "ATTENDANCE TRACKING"
  INSTRUCTIONAL_MINUTES_RECOMMENDED = "INSTRUCTIONAL MINUTES RECOMMENDED"
  DEVICE_DISTRIBUTION = "DEVICE DISTRIBUTION"
  HOTSPOT_ACCESS = "HOTSPOT ACCESS"
  DISTRICT_DELEGATES_LEARNING = "DISTRICT DELEGATES DISTANCE LEARNING PLAN DECISION-MAKING"
  DISTRICT_DELEGATES_DISTANCE_LEARNING_DECISION_MAKING = "DISTRICT DELEGATES DISTANCE LEARNING PLAN DECISION-MAKING"
  SUMMER_LEARNING_PLAN = "SUMMER LEARNING PLAN"
  CONTINGENCY_PLAN_20_21 = "20-21 CONTINGENCY PLAN"
  LEARNING_LOSS_PLAN = "LEARNING LOSS PLAN"
  LEARNING_LOSS_DIAGNOSTIC_IDENTIFIED = "LEARNING LOSS DIAGNOSTIC IDENTIFIED"

  # Tabs
  OVERVIEW = "Overview"
  SUMMER_LEARNING = "Summer Learning"
  RESOURCES = "Resources"
  POLICIES = "Policies"

  # Summer Learning Subtabs
  K8 = "K-8"
  HIGH_SCHOOL = "High School"

  # Policy Subtabs
  TEACHING = "Teaching"
  LEARNING = "Learning"
  PLANNING = "Planning"
  MAIN = 'main' #dummy subtab to indicate there isn't a formal one

  # Subtab Accessors
  TEACHING_MAIN_SUBTAB_ACCESSORS = [
    INSTRUCTION_FROM_TEACHERS,
    SYNCHRONOUS_TEACHING_FLAG,
    FEEDBACK_ON_STUDENT_WORK,
    TEACHER_CHECK_INS,
    SYNCHRONOUS_STUDENT_ENGAGEMENT_FLAG,
  ]

  RESOURCES_MAIN_SUBTAB_ACCESSORS = [
    DEVICE_DISTRIBUTION,
    HOTSPOT_ACCESS,
    RESOURCES_FOR_STUDENTS_WITH_DISABILITIES,
  ]

  POLICIES_LEARNING_SUBTAB_ACCESSORS = [
    # RESOURCES_PROVIDED_BY_THE_DISTRICT,
    RESOURCE_COVERAGE,
    INSTRUCTIONAL_MINUTES_RECOMMENDED,
    FORMAL_GRADING_FLAG,
    ATTENDANCE_TRACKING,
    DISTRICT_DELEGATES_LEARNING,
  ]

  POLICIES_PLANNING_SUBTAB_ACCESSORS = [
    CONTINGENCY_PLAN_20_21,
    LEARNING_LOSS_PLAN,
    SUMMER_LEARNING_PLAN,
    LEARNING_LOSS_DIAGNOSTIC_IDENTIFIED,
  ]

  # Tab accessors
  OVERVIEW_TAB_ACCESSORS = [
  ]

  RESOURCES_TAB_ACCESSORS = [
    {
      tab: RESOURCES,
      subtab: MAIN,
      data_types: RESOURCES_MAIN_SUBTAB_ACCESSORS,
    }
  ]

  POLICIES_TAB_ACCESSORS = [
    {
      tab: POLICIES,
      subtab: PLANNING,
      data_types: POLICIES_PLANNING_SUBTAB_ACCESSORS,
    },
    {
      tab: POLICIES,
      subtab: LEARNING,
      data_types: POLICIES_LEARNING_SUBTAB_ACCESSORS,
    },
    {
      tab: POLICIES,
      subtab: TEACHING,
      data_types: TEACHING_MAIN_SUBTAB_ACCESSORS
    }
  ]

  # All tab accessors
  TAB_ACCESSORS = [
    # {
    #   tab: TEACHING,
    #   accessors: TEACHING_TAB_ACCESSORS
    # },
    {
      tab: RESOURCES,
      accessors: RESOURCES_TAB_ACCESSORS
    },
    {
      tab: POLICIES,
      accessors: POLICIES_TAB_ACCESSORS
    },
  ]
end
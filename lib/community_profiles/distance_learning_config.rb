module CommunityProfiles::DistanceLearningConfig
  # Data Types
  URL = 'URL'
  OVERVIEW = "OVERVIEW" #changed, will be eliminated
  SUMMARY = "SUMMARY"
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
  SUMMER_FALL_PLANNING = "SUMMER FALL PLANNING"
  DISTRICT_DELEGATES_DISTANCE_LEARNING_DECISION_MAKING = "DISTRICT DELEGATES DISTANCE LEARNING PLAN DECISION-MAKING"
  SUMMER_LEARNING_PLAN = "SUMMER LEARNING PLAN"
  CONTINGENCY_PLAN_20_21 = "20-21 CONTINGENCY PLAN"
  LEARNING_LOSS_PLAN = "LEARNING LOSS PLAN"
  LEARNING_LOSS_DIAGNOSTIC_IDENTIFIED = "LEARNING LOSS DIAGNOSTIC IDENTIFIED"

  # Categories
  GENERAL = 'General' # used for general information
  CURRICULUM = "Curriculum"
  INSTRUCTION = "Instruction"
  PROGRESS_MONITORING = "Progress Monitoring"
  CENTRALIZATION = "Centralization"
  LEARNING_TIME = "Learning Time"
  TECHNOLOGY = "Technology"

  ALL_CATEGORIES = [
    CURRICULUM,
    INSTRUCTION,
    PROGRESS_MONITORING,
    CENTRALIZATION,
    LEARNING_TIME,
    TECHNOLOGY
  ]

  # Tabs
  TEACHING = "Teaching"
  RESOURCES = "Resources"
  POLICIES = "Policies"

  # Policy Subtabs
  LEARNING = "Learning"
  PLANNING = "Planning"

  ALL_TABS = [
    TEACHING,
    RESOURCES,
    POLICIES
  ]

  DATA_TYPES_CONFIGS = [
    {
      data_type: URL,
      tab: GENERAL,
      subtab: 'main'
    },
    {
      data_type: OVERVIEW,
      tab: GENERAL,
      subtab: 'main'
    },
    {
      data_type: SUMMARY,
      tab: GENERAL,
      subtab: 'main'
    },
    {
      data_type: INSTRUCTION_FROM_TEACHERS,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: SYNCHRONOUS_TEACHING_FLAG,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: FEEDBACK_ON_STUDENT_WORK,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: TEACHER_CHECK_INS,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: SYNCHRONOUS_STUDENT_ENGAGEMENT_FLAG,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: DEVICE_DISTRIBUTION,
      tab: RESOURCES,
      subtab: 'main'
    },
    {
      data_type: HOTSPOT_ACCESS,
      tab: RESOURCES,
      subtab: 'main'
    },
    {
      data_type: RESOURCES_FOR_STUDENTS_WITH_DISABILITIES,
      tab: RESOURCES,
      subtab: 'main'
    },
    {
      data_type: RESOURCES_PROVIDED_BY_THE_DISTRICT,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: RESOURCE_COVERAGE,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: INSTRUCTIONAL_MINUTES_RECOMMENDED,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: FORMAL_GRADING_FLAG,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: ATTENDANCE_TRACKING,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: DISTRICT_DELEGATES_LEARNING,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: CONTINGENCY_PLAN_20_21,
      tab: POLICIES,
      subtab: PLANNING
    },
    {
      data_type: LEARNING_LOSS_PLAN,
      tab: POLICIES,
      subtab: PLANNING
    },
    {
      data_type: SUMMER_LEARNING_PLAN,
      tab: POLICIES,
      subtab: PLANNING
    },
    {
      data_type: LEARNING_LOSS_DIAGNOSTIC_IDENTIFIED,
      tab: POLICIES,
      subtab: PLANNING
    },
    # {
    #   data_type: SUMMER_FALL_PLANNING,
    #   tab: POLICIES,
    #   subtab: PLANNING
    # },
    # {
    #   data_type: DISTRICT_DELEGATES_DISTANCE_LEARNING_DECISION_MAKING,
    #   tab: POLICIES,
    #   subtab: PLANNING
    # },
  ]
end
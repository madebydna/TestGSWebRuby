module CommunityProfiles::DistanceLearningConfig
  # Data Types
  URL = 'URL'
  OVERVIEW = "OVERVIEW"
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
      category: GENERAL,
      tab: GENERAL,
      subtab: 'main'
    },
    {
      data_type: OVERVIEW,
      category: GENERAL,
      tab: GENERAL,
      subtab: 'main'
    },
    {
      data_type: INSTRUCTION_FROM_TEACHERS,
      category: INSTRUCTION,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: SYNCHRONOUS_TEACHING_FLAG,
      category: INSTRUCTION,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: FEEDBACK_ON_STUDENT_WORK,
      category: PROGRESS_MONITORING,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: TEACHER_CHECK_INS,
      category: PROGRESS_MONITORING,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: SYNCHRONOUS_STUDENT_ENGAGEMENT_FLAG,
      category: INSTRUCTION,
      tab: TEACHING,
      subtab: 'main'
    },
    {
      data_type: DEVICE_DISTRIBUTION,
      category: TECHNOLOGY,
      tab: RESOURCES,
      subtab: 'main'
    },
    {
      data_type: HOTSPOT_ACCESS,
      category: TECHNOLOGY,
      tab: RESOURCES,
      subtab: 'main'
    },
    {
      data_type: RESOURCES_FOR_STUDENTS_WITH_DISABILITIES,
      category: INSTRUCTION,
      tab: RESOURCES,
      subtab: 'main'
    },
    {
      data_type: RESOURCES_PROVIDED_BY_THE_DISTRICT,
      category: CURRICULUM,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: RESOURCE_COVERAGE,
      category: CURRICULUM,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: INSTRUCTIONAL_MINUTES_RECOMMENDED,
      category: LEARNING_TIME,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: FORMAL_GRADING_FLAG,
      category: PROGRESS_MONITORING,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: ATTENDANCE_TRACKING,
      category: LEARNING_TIME,
      tab: POLICIES,
      subtab: LEARNING
    },
    {
      data_type: DISTRICT_DELEGATES_LEARNING,
      category: CENTRALIZATION,
      tab: POLICIES,
      subtab: LEARNING
    },
  ]
end
require "spec_helper"

describe CommunityProfiles::DistanceLearningConfig do
  context 'TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TAB_ACCESSORS.map {|accessor| accessor[:tab]}).to match_array([
        'Overview',
        'Health & safety',
        'Teaching',
        'Policies',
        'Student support'
      ])
    end
  end

  context 'OVERVIEW_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::OVERVIEW_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::OVERVIEW_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'main'
      ])
    end
  end

  context 'HEALTH_AND_SAFETY_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::HEALTH_AND_SAFETY_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::HEALTH_AND_SAFETY_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'main'
      ])
    end
  end

  context 'TEACHING_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'Instruction',
        'Support'
      ])
    end
  end

  context 'POLICIES_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'Learning model',
        'Academics',
        'Learning loss'
      ])
    end
  end

  context 'STUDENT_SUPPORT_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::STUDENT_SUPPORT_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::STUDENT_SUPPORT_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'Resources',
        'Special needs'
      ])
    end
  end

  context 'OVERVIEW_MAIN_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::OVERVIEW_MAIN_SUBTAB_ACCESSORS).to be_an(Array)
    end
  end

  context 'HEALTH_AND_SAFETY_MAIN_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::HEALTH_AND_SAFETY_MAIN_SUBTAB_ACCESSORS).to be_an(Array)
    end
  end

  context 'TEACHING_INSTRUCTION_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_INSTRUCTION_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_INSTRUCTION_SUBTAB_ACCESSORS).to match_array([
        "TYPE OF REMOTE INSTRUCTION OFFERED TO STUDENTS",
        "DISTRICT REQUIRES TEACHER-FAMILY CHECK-INS WHEN ENGAGED IN REMOTE LEARNING",
        "DISTRICT REQUIRES TEACHER-STUDENT CHECK-INS WHEN ENGAGED IN REMOTE LEARNING",
        "DISTRICT EXPECTS TEACHERS TO PROVIDE FEEDBACK ON STUDENT WORK FOR STUDENTS ENGAGED IN REMOTE LEARNING"
      ])
    end
  end

  context 'TEACHING_SUPPORT_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_SUPPORT_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_SUPPORT_SUBTAB_ACCESSORS).to match_array([
        "DISTRICT OFFERED SUMMER PROFESSIONAL DEVELOPMENT",
        "DISTRICT INCREASES TIME DEDICATED TO TEACHER PD OR COLLABORATION",
        "DISTRICT HAS PLAN TO PROVIDE COACHING AND SUPPORT TO TEACHERS DURING THE YEAR IN REMOTE LEARNING SETTING"
      ])
    end
  end

  context 'POLICIES_LEARNING_MODEL_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_MODEL_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_MODEL_SUBTAB_ACCESSORS).to match_array([
        "START-OF-YEAR ANTICIPATED LEARNING MODEL",
        "DISTRICT MENTIONS RACIAL EQUITY AS A PRIORITY OR CONSIDERS RACIAL EQUITY IN WHICH STUDENTS TO PRIORITIZE FOR SERVICES AND IN-PERSON INSTRUCTION"
      ])
    end
  end

  context 'POLICIES_ACADEMICS_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_ACADEMICS_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_ACADEMICS_SUBTAB_ACCESSORS).to match_array([
        "DISTRICT WILL PROVIDE REMOTE CURRICULUM FOR ALL GRADE LEVELS",
        "DISTRICT REQUIRES SCHOOLS TO PROVIDE STUDENT GRADES",
        "DISTRICT REQUIRES SCHOOLS TO TAKE ATTENDANCE",
        "PLAN NAMES REQUIRED MINIMUM NUMBER OF INSTRUCTIONAL MINUTES",
        "DISTRICT HAS A PLAN FOR SUPPORTING HIGH SCHOOL STUDENTS WITH COLLEGE AND CAREER PREPARATION"
      ])
    end
  end

  context 'POLICIES_LEARNING_LOSS_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_LOSS_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_LOSS_SUBTAB_ACCESSORS).to match_array([
        "DISTRICT EXPECTS SCHOOLS TO DIAGNOSE ENTERING STUDENT LEARNING LOSS",
        "DISTRICT HAS A PLAN TO PROVIDE INTERVENTIONS OR INCREASED SUPPORTS BASED ON STUDENT LEARNING LOSS DIAGNOSTIC",
        "DISTRICT HAS A PLAN TO MONITOR STUDENTS' ACADEMIC PROGRESS THROUGHOUT THE YEAR"
      ])
    end
  end

  context 'STUDENT_SUPPORT_RESOURCES_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::STUDENT_SUPPORT_RESOURCES_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::STUDENT_SUPPORT_RESOURCES_SUBTAB_ACCESSORS).to match_array([
        "PLAN COMMITS TO PROVIDE DEVICES FOR ALL STUDENTS IN NEED",
        "PLAN COMMITS TO PROVIDE HOTSPOT/WIFI ACCESS FOR ALL STUDENTS IN NEED",
        "DISTRICT OFFERS GUIDANCE OR TRAINING TO PARENTS IN HOW TO HELP STUDENTS LEARN AT HOME",
        "DISTRICT EXPECTS ALL SCHOOLS TO PROVIDE ACCESS TO COUNSELORS OR SOCIAL WORKERS",
        "DISTRICT HAS A PLAN TO PROVIDE SOCIAL, EMOTIONAL, AND MENTAL HEALTH SERVICES"
      ])
    end
  end

  context 'STUDENT_SUPPORT_SPECIAL_NEEDS_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::STUDENT_SUPPORT_SPECIAL_NEEDS_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::STUDENT_SUPPORT_SPECIAL_NEEDS_SUBTAB_ACCESSORS).to match_array([
        "DISTRICT HAS A PLAN TO PROVIDE SPECIFIC SUPPORT TO STUDENTS WITH DISABILITIES",
        "DISTRICT HAS A PLAN TO PROVIDE SPECIFIC SUPPORT TO STUDENTS WITH LANGUAGE BARRIERS",
        "DISTRICT HAS A PLAN TO PROVIDE SPECIFIC SUPPORT TO STUDENTS EXPERIENCING HOMELESSNESS OR TRANSITIONAL STUDENTS"
      ])
    end
  end
end
require "spec_helper"

describe CommunityProfiles::DistanceLearningConfig do
  context 'TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TAB_ACCESSORS.map {|accessor| accessor[:tab]}).to match_array([
        'Overview',
        'Summer Learning',
        'Resources',
        'Policies',
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

  context 'SUMMER_LEARNING_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::SUMMER_LEARNING_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::SUMMER_LEARNING_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'K-8',
        'High School'
      ])
    end
  end

  context 'RESOURCES_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'main'
      ])
    end
  end

  context 'POLICIES_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TAB_ACCESSORS.map {|accessor| accessor[:subtab]}).to match_array([
        'Planning',
        'Learning',
        'Teaching'
      ])
    end
  end

  context 'OVERVIEW_MAIN_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::OVERVIEW_MAIN_SUBTAB_ACCESSORS).to be_an(Array)
    end
  end

  context 'SUMMER_LEARNING_K8_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::SUMMER_LEARNING_K8_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::SUMMER_LEARNING_K8_SUBTAB_ACCESSORS).to match_array([
        "ES MS SUMMER PROGRAM",
        "ES MS CONTENT: MAKE-UP",
        "ES MS CONTENT: ENRICHMENT"
      ])
    end
  end

  context 'SUMMER_LEARNING_HIGH_SCHOOL_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::SUMMER_LEARNING_HIGH_SCHOOL_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::SUMMER_LEARNING_HIGH_SCHOOL_SUBTAB_ACCESSORS).to match_array([
        "HS SUMMER PROGRAM",
        "HS CONTENT: LEARNING LOSS",
        "HS CONTENT: CREDIT RECOVERY",
        "HS CONTENT: CREDIT ACCELERATION",
        "HS CONTENT: ENRICHMENT"
      ])
    end
  end

  context 'RESOURCES_MAIN_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_MAIN_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_MAIN_SUBTAB_ACCESSORS).to match_array([
        "DEVICE DISTRIBUTION",
        "HOTSPOT ACCESS",
        "SUMMER MEAL PLAN",
        "RESOURCES FOR STUDENTS WITH DISABILITIES",
      ])
    end
  end

  context 'POLICIES_LEARNING_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_SUBTAB_ACCESSORS).to match_array([
        "RESOURCE COVERAGE",
        "INSTRUCTIONAL MINUTES RECOMMENDED",
        "FORMAL GRADING FLAG",
        "ATTENDANCE TRACKING",
        "DISTRICT DELEGATES DISTANCE LEARNING PLAN DECISION-MAKING",
      ])
    end
  end

  context 'POLICIES_PLANNING_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_PLANNING_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_PLANNING_SUBTAB_ACCESSORS).to match_array([
        "20-21 CONTINGENCY PLAN",
        "LEARNING LOSS PLAN",
        "LEARNING LOSS DIAGNOSTIC IDENTIFIED",
      ])
    end
  end

  context 'POLICIES_TEACHING_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TEACHING_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab accessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TEACHING_SUBTAB_ACCESSORS).to match_array([
        "INSTRUCTION FROM TEACHERS",
        "SYNCHRONOUS TEACHING FLAG",
        "FEEDBACK ON STUDENT WORK",
        "TEACHER CHECK-INS",
        "SYNCHRONOUS STUDENT ENGAGEMENT FLAG",
      ])
    end
  end
end
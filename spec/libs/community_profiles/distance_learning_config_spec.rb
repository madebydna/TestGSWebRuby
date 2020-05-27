require "spec_helper"

describe CommunityProfiles::DistanceLearningConfig do
  context 'TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TAB_ACCESSORS.map {|asscessor| asscessor[:tab]}).to match_array([
        'Teaching',
        'Resources',
        'Policies',
      ])
    end
  end

  context 'TEACHING_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_TAB_ACCESSORS.map {|asscessor| asscessor[:subtab]}).to match_array([
        'main'
      ])
    end
  end

  context 'RESOURCES_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_TAB_ACCESSORS.map {|asscessor| asscessor[:subtab]}).to match_array([
        'main'
      ])
    end
  end

  context 'POLICIES_TAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_TAB_ACCESSORS.map {|asscessor| asscessor[:subtab]}).to match_array([
        'Learning',
        'Planning'
      ])
    end
  end

  context 'TEACHING_MAIN_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_MAIN_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::TEACHING_MAIN_SUBTAB_ACCESSORS).to match_array([
        "INSTRUCTION FROM TEACHERS",
        "SYNCHRONOUS TEACHING FLAG",
        "FEEDBACK ON STUDENT WORK",
        "TEACHER CHECK-INS",
        "SYNCHRONOUS STUDENT ENGAGEMENT FLAG",
      ])
    end
  end

  context 'RESOURCES_MAIN_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_MAIN_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::RESOURCES_MAIN_SUBTAB_ACCESSORS).to match_array([
        "DEVICE DISTRIBUTION",
        "HOTSPOT ACCESS",
        "RESOURCES FOR STUDENTS WITH DISABILITIES",
      ])
    end
  end

  context 'POLICIES_LEARNING_SUBTAB_ACCESSORS' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_LEARNING_SUBTAB_ACCESSORS).to be_an(Array)
    end

    it 'contains a list of defined subtab asscessors' do
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

    it 'contains a list of defined subtab asscessors' do
      expect(CommunityProfiles::DistanceLearningConfig::POLICIES_PLANNING_SUBTAB_ACCESSORS).to match_array([
        "20-21 CONTINGENCY PLAN",
        "LEARNING LOSS PLAN",
        "SUMMER LEARNING PLAN",
        "LEARNING LOSS DIAGNOSTIC IDENTIFIED",
      ])
    end
  end
end
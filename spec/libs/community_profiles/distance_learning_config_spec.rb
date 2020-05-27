require "spec_helper"

describe CommunityProfiles::DistanceLearningConfig do
  context 'ALL_CATEGORIES' do
    it 'is an array' do
      expect(CommunityProfiles::DistanceLearningConfig::ALL_CATEGORIES).to be_an(Array)
    end

    it 'contains a list of defined string' do
      expect(CommunityProfiles::DistanceLearningConfig::ALL_CATEGORIES).to match_array([
        'Curriculum',
        'Instruction',
        'Progress Monitoring',
        'Centralization',
        'Learning Time',
        'Technology'
      ])
    end
  end

  context 'DATA_TYPES_CONFIGS' do
    it 'is and array' do
      expect(CommunityProfiles::DistanceLearningConfig::DATA_TYPES_CONFIGS).to be_a(Array)
    end

    it 'contains an array of hashes with data_types that are defined' do
      expect(CommunityProfiles::DistanceLearningConfig::DATA_TYPES_CONFIGS.map {|config| config[:data_type]}).to match_array([
        'URL',
        "SUMMARY",
        "RESOURCES PROVIDED BY THE DISTRICT",
        "RESOURCE COVERAGE",
        "INSTRUCTION FROM TEACHERS",
        "SYNCHRONOUS TEACHING FLAG",
        "SYNCHRONOUS STUDENT ENGAGEMENT FLAG",
        "RESOURCES FOR STUDENTS WITH DISABILITIES",
        "FEEDBACK ON STUDENT WORK",
        "FORMAL GRADING FLAG",
        "TEACHER CHECK-INS",
        "ATTENDANCE TRACKING",
        "INSTRUCTIONAL MINUTES RECOMMENDED",
        "DEVICE DISTRIBUTION",
        "HOTSPOT ACCESS",
        "DISTRICT DELEGATES DISTANCE LEARNING PLAN DECISION-MAKING"
      ])
    end

    it 'contains an array of hashes with categories that are defined' do
      expect(CommunityProfiles::DistanceLearningConfig::DATA_TYPES_CONFIGS.map {|config| config[:category]}).to match_array([
        'General',
        'General',
        'Curriculum',
        'Curriculum',
        'Instruction',
        'Instruction',
        'Instruction',
        'Instruction',
        'Progress Monitoring',
        'Progress Monitoring',
        'Progress Monitoring',
        'Centralization',
        'Learning Time',
        'Learning Time',
        'Technology',
        'Technology'
      ])
    end
  end
end
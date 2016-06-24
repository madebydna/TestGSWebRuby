module Feeds
  class TestDataSetDecorator
    include Feeds::FeedConstants

    @@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
    @@test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
    @@test_data_breakdowns = Hash[TestDataBreakdown.all.map { |bd| [bd.id, bd] }]
    @@test_data_breakdowns_name_mapping = Hash[TestDataBreakdown.all.map { |bd| [bd.name, bd] }]

    attr_reader :test_data_set, :state

    def initialize(state, test_data_set)
      @state = state
      @test_data_set = test_data_set
    end

    def proficiency_band_id(entity_level)
      # For proficient and above band id is always null in database
      test_data_set['proficiency_band_id']
    end

    def proficiency_band_name
      if @@proficiency_bands[test_data_set['proficiency_band_id']].present?
        @@proficiency_bands[test_data_set['proficiency_band_id']].name || PROFICIENT_AND_ABOVE_BAND
      else
        PROFICIENT_AND_ABOVE_BAND
      end
    end

    def subject_name
      @@test_data_subjects[test_data_set.subject_id].present? ? @@test_data_subjects[test_data_set.subject_id].name : ''
    end

    def breakdown_id
      name = breakdown_name == 'All' ? 'All students' : breakdown_name
      test_data_set['breakdown_id'].present? ? test_data_set['breakdown_id'] : @@test_data_breakdowns_name_mapping[name].try(:id)
    end

    def breakdown_name
      @@test_data_breakdowns[test_data_set.breakdown_id].present? ? @@test_data_breakdowns[test_data_set.breakdown_id].name : ''
    end

    def number_tested(entity_level)
      test_data_set['number_students_tested']
    end

    def method_missing(method, *args)
      test_data_set.send(method, *args)
    end

    def test_id
      state.upcase + test_data_set['data_type_id'].to_s.rjust(5, '0')
    end

    def grade_name
      test_data_set['grade_name']
    end

    def test_score(entity_level)
      if entity_level == ENTITY_TYPE_STATE
        # Get Score from Data which is in Active Record
        test_data_set.state_value_text || test_data_set.state_value_float
      else
        if proficiency_band_name == PROFICIENT_AND_ABOVE_BAND
          test_data_set['score']
        else
          test_data_set[proficiency_band_name+'_score']
        end
      end
    end

    def universal_id(entity = nil, entity_level)
      if entity_level == ENTITY_TYPE_DISTRICT
        '1' + state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
      elsif entity_level == ENTITY_TYPE_SCHOOL
        state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
      else
        state_fips[state.upcase]
      end
    end
  end
end
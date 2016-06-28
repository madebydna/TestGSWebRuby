module Feeds
  class TestDataSetHashDecorator
    include Feeds::FeedConstants

    @@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
    @@test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
    @@test_data_breakdowns = Hash[TestDataBreakdown.all.map { |bd| [bd.id, bd] }]
    @@test_data_breakdowns_name_mapping = Hash[TestDataBreakdown.all.map { |bd| [bd.name, bd] }]

    attr_reader :test_data_object, :state

    def initialize(state, test_data_hash)
      @state = state
      @test_data_object = OpenStruct.new(test_data_hash)
    end

    # delagate some accessor methods to wrapped object
    [:subject, :year, :breakdown, :grade, :level].each do |method|
      define_method(method) do
        test_data_object.send(method)
      end
    end

    def test_id
      state.upcase + test_data_object.test_id.to_s.rjust(5, '0')
    end

    def proficiency_band_id
      if proficiency_band_name == PROFICIENT_AND_ABOVE_BAND
        nil # TODO: really?
      else
        test_data_object.send("#{proficiency_band_name}_band_id")
      end
    end

    def proficiency_band_name
      test_data_object.proficiency_band || PROFICIENT_AND_ABOVE_BAND
    end

    def breakdown_name
      breakdown
    end

    def level_code
      level
    end

    def number_tested
      if proficiency_band_name == PROFICIENT_AND_ABOVE_BAND
        test_data_object.number_students_tested
      else
        test_data_object.send("#{proficiency_band_name}_number_students_tested")
      end
    end

    def test_score
      if proficiency_band_name == PROFICIENT_AND_ABOVE_BAND
        test_data_object.score
      else
        test_data_object.send("#{proficiency_band_name}_score")
      end
    end

    def universal_id
      test_data_object.universal_id
    end

  end
end

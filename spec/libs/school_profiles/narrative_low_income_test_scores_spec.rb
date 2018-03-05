require "spec_helper"

describe SchoolProfiles::NarrativeLowIncomeTestScores do

  describe "#new" do
    it "should change test score hash correctly" do
      narrativeLowIncomeTestScores = SchoolProfiles::NarrativeLowIncomeTestScores.new(test_scores_hashes: test_scores_hash)
      allow(narrativeLowIncomeTestScores).to receive(:key_for_yml).and_return '4'
      result = narrativeLowIncomeTestScores.auto_narrative_calculate_and_add
      expect(result.values.flatten.map(&:to_hash)).to eq(result_hash.values.flatten.map(&:to_hash))
    end

    it "should have the right narrative" do
      narrativeLowIncomeTestScores = SchoolProfiles::NarrativeLowIncomeTestScores.new(test_scores_hashes: test_scores_hash)
      allow(narrativeLowIncomeTestScores).to receive(:key_for_yml).and_return '4'
      result = narrativeLowIncomeTestScores.auto_narrative_calculate_and_add
      expect(result.values.flatten.map { |o| o[:narrative] }).to eq(result_hash.values.flatten.map { |o| o[:narrative] })
    end

    it 'should change a test score hash with alternate level code and subject names correctly' do
      narrativeLowIncomeTestScores = SchoolProfiles::NarrativeLowIncomeTestScores.new(test_scores_hashes: test_scores_hash_2)
      allow(narrativeLowIncomeTestScores).to receive(:key_for_yml).and_return '4'
      result = narrativeLowIncomeTestScores.auto_narrative_calculate_and_add
      expect(result.values.flatten.map(&:to_hash)).to eq(result_hash_2.values.flatten.map(&:to_hash))
    end
  end

  def result_hash
    {
      236 => GsdataCaching::GsDataValue.from_array_of_hashes([
        {
          "data_type" => 236,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'English Language Arts',
          "year" => 2015,
          "number_students_tested"=>344,
          "school_value"=>72.0,
          "state_value"=>44.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'Math',
          "year" => 2015,
          "number_students_tested"=>343,
          "school_value"=>55.0,
          "state_value"=>33.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'English Language Arts',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>78.0,
          "state_value"=>64.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Math',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>58.0,
          "state_value"=>52.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'English Language Arts',
          "year" => 2015,
          "number_students_tested"=>99,
          "school_value"=>56.0,
          "state_value"=>30.0,
          "narrative" => t('4', 'English')
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Math',
          "year" => 2015,
          "number_students_tested"=>98,
          "school_value"=>47.0,
          "state_value"=>21.0,
          "narrative" => t('4', 'math') 
        }
      ])
    }
  end

  def result_hash_2
    {
      15 => GsdataCaching::GsDataValue.from_array_of_hashes([
        {
          "data_type" => 15,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'Some subject',
          "year" => 2015,
          "number_students_tested"=>344,
          "school_value"=>72.0,
          "state_value"=>44.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'Some other subject',
          "year" => 2015,
          "number_students_tested"=>343,
          "school_value"=>55.0,
          "state_value"=>33.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some subject',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>78.0,
          "state_value"=>64.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some other subject',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>58.0,
          "state_value"=>52.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some subject',
          "year" => 2015,
          "number_students_tested"=>99,
          "school_value"=>56.0,
          "state_value"=>30.0,
          "narrative" => t('4', 'Some subject')
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some other subject',
          "year" => 2015,
          "number_students_tested"=>98,
          "school_value"=>47.0,
          "state_value"=>21.0,
          "narrative" => t('4', 'Some other subject')
        }
      ])
    }
  end


  def test_scores_hash
    {
      236 => GsdataCaching::GsDataValue.from_array_of_hashes([
        {
          "data_type" => 236,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'English Language Arts',
          "year" => 2015,
          "number_students_tested"=>344,
          "school_value"=>72.0,
          "state_value"=>44.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'Math',
          "year" => 2015,
          "number_students_tested"=>343,
          "school_value"=>55.0,
          "state_value"=>33.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'English Language Arts',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>78.0,
          "state_value"=>64.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Math',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>58.0,
          "state_value"=>52.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'English Language Arts',
          "year" => 2015,
          "number_students_tested"=>99,
          "school_value"=>56.0,
          "state_value"=>30.0
        },
        {
          "data_type" => 236,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Math',
          "year" => 2015,
          "number_students_tested"=>98,
          "school_value"=>47.0,
          "state_value"=>21.0
        }
      ])
    }
  end

  def test_scores_hash_2
    {
      15 => GsdataCaching::GsDataValue.from_array_of_hashes([
        {
          "data_type" => 15,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'Some subject',
          "year" => 2015,
          "number_students_tested"=>344,
          "school_value"=>72.0,
          "state_value"=>44.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'All Students',
          "grade" => 'All',
          "academics" => 'Some other subject',
          "year" => 2015,
          "number_students_tested"=>343,
          "school_value"=>55.0,
          "state_value"=>33.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some subject',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>78.0,
          "state_value"=>64.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Not economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some other subject',
          "year" => 2015,
          "number_students_tested"=>245,
          "school_value"=>58.0,
          "state_value"=>52.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some subject',
          "year" => 2015,
          "number_students_tested"=>99,
          "school_value"=>56.0,
          "state_value"=>30.0
        },
        {
          "data_type" => 15,
          "breakdowns" => 'Economically disadvantaged',
          "grade" => 'All',
          "academics" => 'Some other subject',
          "year" => 2015,
          "number_students_tested"=>98,
          "school_value"=>47.0,
          "state_value"=>21.0
        }
      ])
    }
  end

  def t(yml_key, subject)
    I18n.t(yml_key + '_html', scope: 'lib.test_scores.narrative.low_income', subject: I18n.t(subject, scope: 'lib.equity_gsdata', default: subject))
  end
end

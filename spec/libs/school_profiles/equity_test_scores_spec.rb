require 'spec_helper'
require 'json'

describe SchoolProfiles::EquityTestScores do

  describe 'Equity test score transformation' do

    def mock_school_cache_data_reader_ca1
      double(test_scores: test_scores_ca1, ethnicity_data: ethnicity_data_ca1)
    end

    def mock_school_cache_data_reader_ma949
      double(test_scores: test_scores_ma949, ethnicity_data: ethnicity_data_ma949)
    end

    it 'california 1 all verification' do
      pending('need to have narration written to hash after hash built')
      fail
      # school_cache_data_reader_ca = mock_school_cache_data_reader_ca1
      # SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader_ca).auto_narrative_calculate_and_add
      # equityTestScores_ca = SchoolProfiles::EquityTestScores.new(school_cache_data_reader: school_cache_data_reader_ca)
      # ets_ca = equityTestScores_ca.generate_equity_test_score_hash
      # expect(ets_ca).to eq(equity_test_scores_ca1)
    end

    it 'california 1 low income verification' do
      pending('need to have narration written to hash after hash built')
      fail
      # school_cache_data_reader_ca = mock_school_cache_data_reader_ca1
      # SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader_ca).auto_narrative_calculate_and_add
      # equityTestScores_ca = SchoolProfiles::EquityTestScores.new(school_cache_data_reader: school_cache_data_reader_ca)
      # ets_ca = equityTestScores_ca.generate_equity_test_score_hash
      # expect(ets_ca['low_income']).to eq(equity_test_scores_ca1['low_income'])
    end

    it 'california 1 ethnicity verification' do
      pending('need to have narration written to hash after hash built')
      fail
      # school_cache_data_reader_ca = mock_school_cache_data_reader_ca1
      # equityTestScores_ca = SchoolProfiles::EquityTestScores.new(school_cache_data_reader: school_cache_data_reader_ca)
      # ets_ca = equityTestScores_ca.generate_equity_test_score_hash
      # expect(ets_ca['ethnicity']).to eq(equity_test_scores_ca1['ethnicity'])
    end

    it 'massachusetts 949 all verification' do
      pending('need to have narration written to hash after hash built')
      fail
      # school_cache_data_reader_ma = mock_school_cache_data_reader_ma949
      # SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader_ma).auto_narrative_calculate_and_add
      # equityTestScores_ma = SchoolProfiles::EquityTestScores.new(school_cache_data_reader: school_cache_data_reader_ma)
      # ets_ma = equityTestScores_ma.generate_equity_test_score_hash
      # expect(ets_ma).to eq(equity_test_scores_ma949)
    end

    it 'massachusetts 949 low income verification' do
      pending('need to have narration written to hash after hash built')
      fail
      # school_cache_data_reader_ma = mock_school_cache_data_reader_ma949
      # SchoolProfiles::NarrativeLowIncomeTestScores.new(school_cache_data_reader: school_cache_data_reader_ma).auto_narrative_calculate_and_add
      # equityTestScores_ma = SchoolProfiles::EquityTestScores.new(school_cache_data_reader: school_cache_data_reader_ma)
      # ets_ma = equityTestScores_ma.generate_equity_test_score_hash
      # expect(ets_ma['low_income']).to eq(equity_test_scores_ma949['low_income'])
    end

    it 'massachusetts 949 ethnicity verification' do
      pending('need to have narration written to hash after hash built')
      fail
      # school_cache_data_reader_ma = mock_school_cache_data_reader_ma949
      # equityTestScores_ma = SchoolProfiles::EquityTestScores.new(school_cache_data_reader: school_cache_data_reader_ma)
      # ets_ma = equityTestScores_ma.generate_equity_test_score_hash
      # expect(ets_ma['ethnicity']).to eq(equity_test_scores_ma949['ethnicity'])
    end
  end


  def equity_test_scores_ca1
    file = File.read('./spec/libs/school_profiles/supporting_data/ca1_equity_test_scores.json')
    JSON.parse(file)
  end

  def test_scores_ca1
    file = File.read('./spec/libs/school_profiles/supporting_data/ca1_test_scores.json')
    JSON.parse(file)
  end

  def ethnicity_data_ca1
    file = File.read('./spec/libs/school_profiles/supporting_data/ca1_ethnicity_data.json')
    JSON.parse(file)
  end

  def equity_test_scores_ma949
    file = File.read('./spec/libs/school_profiles/supporting_data/ma949_equity_test_scores.json')
    JSON.parse(file)
  end

  def test_scores_ma949
    file = File.read('./spec/libs/school_profiles/supporting_data/ma949_test_scores.json')
    JSON.parse(file)
  end

  def ethnicity_data_ma949
    file = File.read('./spec/libs/school_profiles/supporting_data/ma949_ethnicity_data.json')
    JSON.parse(file)
  end

end

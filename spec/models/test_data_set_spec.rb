require 'spec_helper'

describe TestScoreResults do
  let(:school) { FactoryGirl.build(:school) }
  #let(:test_data_sets) { FactoryGirl.build_list(:test_data_set_with_values, 5) }
  #expect(subject).to receive(:build_test_scores_hash).with(test_data_sets, data_set_ids)


  describe 'fetch_test_data_sets_and_values' do
    it 'should not return data' do
      test_data_sets_and_values = []

      TestDataSet.stub(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      results = subject.fetch_test_data_sets_and_values school

      expect(results).to be_empty
    end
  end

  describe 'fetch_test_data_sets_and_values' do
    it 'should not return data' do

      TestDataSet.stub(:fetch_test_scores).with(school).and_return(nil)

      results = subject.fetch_test_data_sets_and_values school

      expect(results).to be_empty
    end
  end


  describe 'fetch_test_data_sets_and_values' do
    it 'should not return data' do
      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737}]

      TestDataSet.stub(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      #none of the test_data_sets_and_values have valid entries in test_data_set_file.
      TestDataSetFile.stub(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return([])

      results = subject.fetch_test_data_sets_and_values school

      expect(results).to be_empty
    end
  end

  describe 'fetch_test_data_sets_and_values' do
    it 'should not return data' do
      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737}]

      TestDataSet.stub(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      #none of the test_data_sets_and_values have valid entries in test_data_set_file.
      TestDataSetFile.stub(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return(nil)

      results = subject.fetch_test_data_sets_and_values school

      expect(results).to be_empty
    end
  end


  describe 'fetch_test_data_sets_and_values' do
    it 'should return test data' do
      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737}]

      TestDataSet.stub(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      TestDataSetFile.stub(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return([84122, 84302])

      results = subject.fetch_test_data_sets_and_values school

      expect(results).to_not be_empty
    end
  end

  describe 'fetch_test_data_sets_and_values' do
    it 'should return 2 results' do
      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737}]

      TestDataSet.stub(:fetch_test_scores).with(school).and_return(test_data_sets_and_values)

      #Only 2 of the test_data_sets_and_values have valid entries in test_data_set_file.
      TestDataSetFile.stub(:get_valid_data_set_ids).with([84122, 84302, 84482], school).and_return([84122, 84302])

      results = subject.fetch_test_data_sets_and_values school

      expect(results.size).to eq(2)
    end
  end

  describe 'build_test_scores_hash' do
    it 'should return empty test scores hash' do

      test_scores_hash = subject.build_test_scores_hash []

      expect(test_scores_hash).to be_empty

    end
  end

  describe 'build_test_scores_hash' do
    it 'should return empty test scores hash' do

      test_scores_hash = subject.build_test_scores_hash nil

      expect(test_scores_hash).to be_empty

    end
  end

  describe 'build_test_scores_hash' do
    it 'should return test scores hash' do
      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737},
                                   {:test_data_type_id => 19, :test_data_set_id => 84488, :grade => "8", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737}]

      TestDataType.stub(:by_id).with(18).and_return(FactoryGirl.build(:test_data_type))
      TestDataType.stub(:by_id).with(19).and_return(FactoryGirl.build(:test_data_type))

      test_scores_hash = subject.build_test_scores_hash test_data_sets_and_values

      expect(test_scores_hash.size).to eq(2)
      expect(test_scores_hash[18][:grades].size).to eq(1)
      expect(test_scores_hash[19][:grades].size).to eq(1)
      expect(test_scores_hash[18][:lowest_grade]).to eq(9)
      expect(test_scores_hash[19][:lowest_grade]).to eq(8)
      expect(test_scores_hash[18][:test_description]).to eq("This test is awesome.")
      expect(test_scores_hash[18][:test_label]).to eq("Awesome Test")

    end
  end

  describe 'sort_test_scores' do
    it 'should sort test scores' do
      test_data_sets_and_values = [{:test_data_type_id => 18, :test_data_set_id => 84122, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2010, :school_value_text => nil, :school_value_float => 20.0, :state_value_text => nil, :state_value_float => 22.0, :breakdown_id => 1, :number_tested => 269697},
                                   {:test_data_type_id => 19, :test_data_set_id => 84488, :grade => "7", :level_code => "e,m,h", :subject_id => 11, :year => 2010, :school_value_text => nil, :school_value_float => 90.0, :state_value_text => nil, :state_value_float => 77.0, :breakdown_id => 1, :number_tested => 24737},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 7, :year => 2009, :school_value_text => nil, :school_value_float => 33.0, :state_value_text => nil, :state_value_float => 45.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "8", :level_code => "e,m,h", :subject_id => 9, :year => 2010, :school_value_text => nil, :school_value_float => 31.0, :state_value_text => nil, :state_value_float => 35.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "9", :level_code => "e,m,h", :subject_id => 19, :year => 2009, :school_value_text => nil, :school_value_float => 36.0, :state_value_text => nil, :state_value_float => 55.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84302, :grade => "10", :level_code => "e,m,h", :subject_id => 19, :year => 2009, :school_value_text => nil, :school_value_float => 38.0, :state_value_text => nil, :state_value_float => 56.0, :breakdown_id => 1, :number_tested => 134540},
                                   {:test_data_type_id => 18, :test_data_set_id => 84482, :grade => "9", :level_code => "e,m,h", :subject_id => 11, :year => 2009, :school_value_text => nil, :school_value_float => 80.0, :state_value_text => nil, :state_value_float => 69.0, :breakdown_id => 1, :number_tested => 24737},
                                   {:test_data_type_id => 19, :test_data_set_id => 84488, :grade => "7", :level_code => "e,m,h", :subject_id => 11, :year => 2009, :school_value_text => nil, :school_value_float => 70.0, :state_value_text => nil, :state_value_float => 68.0, :breakdown_id => 1, :number_tested => 24737},
      ]

      TestDataType.stub(:by_id).with(18).and_return(FactoryGirl.build(:test_data_type))
      TestDataType.stub(:by_id).with(19).and_return(FactoryGirl.build(:test_data_type))
      test_scores_hash = subject.build_test_scores_hash test_data_sets_and_values
      sorted_test_scores = subject.sort_test_scores test_scores_hash

      expect(sorted_test_scores.size).to eq(2)

      #test should be sorted by the lowest grade. Hence test data type id 19 should be first.
      expect(sorted_test_scores.keys[0]).to eq(19)
      expect(sorted_test_scores.keys[1]).to eq(18)

      #grades should be sorted in ascending order.
      expect(sorted_test_scores.values[1][:grades].keys[0]).to eq ("8")
      expect(sorted_test_scores.values[1][:grades].keys[1]).to eq ("9")
      expect(sorted_test_scores.values[1][:grades].keys[2]).to eq ("10")

      #subjects should be sorted in alphabetical order.
      expect(sorted_test_scores.values[1][:grades].values[1].values[0].keys[0]).to eq ("algebra 1")
      expect(sorted_test_scores.values[1][:grades].values[1].values[0].keys[1]).to eq ("algebra 2")
      expect(sorted_test_scores.values[1][:grades].values[1].values[0].keys[2]).to eq ("english")

      #years are sorted in descending order.
      expect(sorted_test_scores.values[1][:grades].values[1].values[0].values[0].keys[0]).to eq (2010)
      expect(sorted_test_scores.values[1][:grades].values[1].values[0].values[0].keys[1]).to eq (2009)

    end
  end

end
require 'spec_helper'

describe TestScoreResults do
  let(:school) { FactoryGirl.build(:school) }

  context 'no test data found' do
    it 'should return nil' do
      TestDataSet.stub(:fetch_test_scores).and_return({})
      TestDataSetFile.stub(:get_valid_data_set_ids).and_return([])

      subject.fetch_results(school).should be_nil
    end

    it 'should return nil' do
      TestDataSet.stub(:fetch_test_scores).and_return(nil)
      TestDataSet.stub(:get_valid_data_set_ids).and_return(nil)

      subject.fetch_results(school).should be_nil
    end
  end

  #let(:test_data_sets) { FactoryGirl.build_list(:test_data_set_with_values, 5) }

  it 'should build test scores hash' do

    data_set_ids = [1, 2, 3, 4]
    test_data_sets = double(TestDataSet)

    TestDataSet.stub(:fetch_test_scores).and_return(test_data_sets)
    test_data_sets.stub(:pluck).and_return(data_set_ids)
    TestDataSetFile.stub(:get_valid_data_set_ids).and_return(data_set_ids)
    expect(subject).to receive(:build_test_scores_hash).with(test_data_sets, data_set_ids)
    subject.fetch_results(school)
  end



end
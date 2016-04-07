require 'spec_helper'
require 'models/schools/testscores/testscores_shared_contexts'
require 'models/schools/testscores/testscores_shared_examples'

describe TestDataSet do
  subject { TestDataSet }

  describe '#ratings_for_school' do
    with_shared_context 'when there is a deactivated test_data_set' do
      include_example 'should not return a test_data_set'
    end

    with_shared_context 'when there is an active test_data_set with a deactivated test_data_school_value' do
      include_example 'should not return a test_data_set'
    end

  end

  describe '#fetch_feed_test_scores' do
    #  Commenting the test case as test query is failing as itg is a join between non sharded and sharded db abd need to investigate with factory girl

    # with_shared_context 'when there is an active feed test_data_set' do
    #
    #   it {expect(subject.fetch_feed_test_scores(school).to_a).to_not be_empty}
    # end
    # with_shared_context 'when there is an inactive feed test_data_set' do
    #   it {expect(subject.fetch_feed_test_scores(school).to_a).to be_empty}
    # end
    # with_shared_context 'when there is an active feed test_data_set with a deactivated test_data_school_value' do
    #   it {expect(subject.fetch_feed_test_scores(school).to_a).to be_empty}
    # end
  end

  describe '#fetch_test_scores' do
    # pending
    with_shared_context 'when there is an active desktop test_data_set' do
      it {expect(subject.fetch_test_scores(school).to_a).to_not be_empty}
    end
    # pending
    with_shared_context 'when there is an inactive desktop test_data_set' do
      it {expect(subject.fetch_test_scores(school).to_a).to be_empty}
    end
    # pending
    with_shared_context 'when there is an active desktop test_data_set with a deactivated test_data_school_value' do
      it {expect(subject.fetch_test_scores(school).to_a).to be_empty}
    end
  end

  describe '#base_performance_query' do
    let(:school) { FactoryGirl.build(:school, id: 1) }
    describe 'with no data' do
      it {expect(subject.base_performance_query(school).to_a).to be_empty}
    end
  end
end

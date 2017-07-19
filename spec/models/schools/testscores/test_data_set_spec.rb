require 'spec_helper'
require 'models/schools/testscores/testscores_shared_contexts'
require 'models/schools/testscores/testscores_shared_examples'

describe TestDataSet do
  subject { TestDataSet }

  describe '#ratings_for_school' do
    # with_shared_context 'when there is a deactivated test_data_set' do
    #   include_example 'should not return a test_data_set'
    # end
    #
    # with_shared_context 'when there is an active test_data_set with a deactivated test_data_school_value' do
    #   include_example 'should not return a test_data_set'
    # end

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

  describe '.ratings_for_school' do
    let(:school) { FactoryGirl.build(:school, id: 1) }
    describe 'query criteria' do
      subject { TestDataSet.ratings_for_school(school) }
      it { is_expected.to_not include('breakdown') }
      # couldn't figure out a straightforward way to check
      # joined fields like TDT classification or school_id. Could call
      # .to_sql on the ActiveRelation and then do a substring match
      its('where_values_hash.active') { is_expected.to eq(1) }

      its('to_sql') { is_expected.to include("display_target like '%ratings%'") }
      its('to_sql') { is_expected.to include("classification = 'gs_rating'") }
    end
  end

  describe '.historic_ratings_for_school' do
    let(:school) { FactoryGirl.build(:school, id: 1) }
    describe 'query criteria' do
      subject { TestDataSet.historic_ratings_for_school(school, [1,2], [3,4]) }
      its(:where_values_hash) { is_expected.to include('breakdown_id') }
      its('where_values_hash.breakdown_id') { is_expected.to eq(1) }
      its('where_values_hash.data_type_id') { is_expected.to eq([1,2]) }
      its('where_values_hash.active') { is_expected.to eq(1) }
      its('to_sql') { is_expected.to include("classification = 'gs_rating'") }
    end
  end

end

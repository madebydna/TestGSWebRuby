require 'spec_helper'
require 'models/schools/testscores/testscores_shared_contexts'
require 'models/schools/testscores/testscores_shared_examples'

describe TestDataSet do
  describe '#ratings_for_school' do

    subject { TestDataSet }

    with_shared_context 'when there is a deactivated test_data_set' do
      include_example 'should not return a test_data_set'
    end

    with_shared_context 'when there is an active test_data_set with a deactivated test_data_school_value' do
      include_example 'should not return a test_data_set'
    end

  end
end

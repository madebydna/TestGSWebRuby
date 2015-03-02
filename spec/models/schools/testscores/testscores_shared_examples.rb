require 'spec_helper'

shared_example 'should not return a test_data_set' do
  expect(subject.ratings_for_school(school)).to be_empty
end

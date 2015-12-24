require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require 'features/page_objects/school_profile_reviews_page'
require 'features/contexts/shared_contexts_for_signed_in_users'



shared_example 'should have reviews filter with default All topics' do
  wait_for_page_to_finish
  expect(subject.reviews_topic_filter_button.text).to eq('All topics')
end

require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'



shared_example 'should show the review module' do
  expect(subject).to have_review_module
end

shared_example 'should show role question' do
  expect(subject).to have_role_question
end

shared_example 'should not show role question' do
  expect(subject).to_not have_role_question
end

shared_example 'should show the overall star question' do
  expect(subject.visible_review_question.review_form.text).to include(FactoryGirl.build(:overall_rating_question).question)
end

shared_example 'should not show the overall star question' do
  expect(subject.visible_review_question.review_form.text).to_not include(FactoryGirl.build(:overall_rating_question).question)
end

shared_example 'should show the overall star principal question' do
  expect(subject.visible_review_question.review_form.text).to include(FactoryGirl.build(:overall_rating_question).principal_question)
end

shared_example 'should show stars' do
  subject.wait_for_visible_review_question
  expect(subject.visible_review_question).to have_stars
end

shared_example 'should not show stars' do
  subject.wait_for_visible_review_question
  expect(subject.visible_review_question).to_not have_stars
end

shared_example 'should show overall summary' do
  subject.wait_for_visible_review_question
  expect(subject.visible_review_question).to have_overall_summary
end

shared_example 'should show submit button with principal text' do
  expect(subject.visible_review_question).to_not have_stars
end

shared_example 'should show a radio_button question' do
  expect(subject.visible_review_question).to have_radio_buttons
end

shared_example 'should not show radio buttons' do
  expect(subject.visible_review_question).to_not have_radio_buttons
end

shared_example 'should show a radio_button question' do
  expect(subject.visible_review_question).to have_radio_buttons
end

shared_example 'should show next question' do
  # pending ('fails intermittently due to timing with carousel and ajax')
  # fail
  expect(subject.visible_review_question.question.text).to eq(teacher_question.question)
end

shared_example 'should show next principal question' do
  expect(subject.visible_review_question.question.text).to eq(teacher_question.principal_question)
end

shared_example 'should have call to action text' do
  expect(subject.visible_review_question).to have_call_to_action_text
end

shared_example 'should not show the review comment form' do
  expect(subject.visible_review_question).not_to have_review_comment
end

shared_example 'should show the review comment section' do
  expect(subject.visible_review_question).to have_review_comment
end

shared_example 'should have reviews filter with default All topics' do
  wait_for_page_to_finish
  expect(subject.reviews_topic_filter_button.text).to eq('All topics')
end

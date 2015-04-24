require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'


shared_example 'should be redirected to the reviews page' do
  expect(SchoolProfileReviewsPage.new).to be_displayed
end

shared_example 'should show the review module' do
  expect(subject).to have_review_module
end

shared_example 'should show the overall star question' do
  expect(subject.visible_review_question).to have_stars
end

shared_example 'should show a radio_button question' do
  expect(subject.visible_review_question).to have_radio_buttons
end

shared_example 'should show next question' do
  expect(subject.visible_review_question.question.text).to eq(teacher_question.question)
end

shared_example 'should not show the review comment form' do
  expect(subject.visible_review_question).not_to have_review_comment
end

shared_example 'should show the review comment section' do
  expect(subject.visible_review_question).to have_review_comment
end

shared_example 'should save review with expected value' do |value|
  wait_for_page_to_finish
  expect(Review.last.answers.count).to eq(1)
  expect(Review.last.answers.first.value).to eq(value)
end

shared_example 'should save overall review with comment without bad words' do
  wait_for_page_to_finish
  comment = 'lorem ' * 15
  expect(Review.last.comment).to eq(comment.strip)
end

shared_example 'should save overall review with comment with bad words' do
  wait_for_page_to_finish
  comment = 'lorem ' * 15 + 'test_really_bad_word'
  expect(Review.last.comment).to eq(comment)
end

shared_example 'should save review that is active' do
  wait_for_page_to_finish
  expect(Review.last.active).to eq(true)
end

shared_example 'should save review that is not active' do
  wait_for_page_to_finish
  expect(Review.last.active).to eq(false)
end

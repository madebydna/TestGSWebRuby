require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'


shared_context 'with two topics and questions' do
  # create topics- requires that a school was set by previous context
  let(:topic) { FactoryGirl.create(:review_topic, school_level: school.level_code, school_type: school.type) }
  let(:topic2) { FactoryGirl.create(:review_topic, name: 'Topic2', school_level: school.level_code, school_type: school.type) }
  # create questions for topic
  # Execute immediately
  let!(:review_question) { FactoryGirl.create(:review_question, review_topic: topic) }
  let!(:review_question2) { FactoryGirl.create(:review_question, review_topic: topic2, question: 'How you like Elvis?') }

  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'Click Question Response' do
  before do
    response_option = subject.visible_review_question.responses.first
    response_option.click
  end
end

shared_context 'submit response with valid comment' do
  before do
    fill_in('review[comment]', with: 'lorem ' * 15)
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    wait_for_ajax
  end
end

shared_context 'submit response with bad word' do
  before do
    AlertWord.create!( word: 'test_really_bad_word', really_bad: true )
    fill_in('review[comment]', with: 'lorem ' * 15 + 'test_really_bad_word')
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    wait_for_ajax
  end
end


shared_context 'with signing up for a new account' do
  before do
    fill_in(:email, with: 'test@greatschools.org')
    check('terms[terms]')
    click_button('Sign Up')
  end
end

shared_context 'with signing into a verified account' do
  before do
    click_link('Login')
    user = FactoryGirl.create(:verified_user)
    log_in_user(user)
    fill_in(:email, with: user.email)
    fill_in(:password, with: user.password)
    click_button('Login')
  end
  after do
    clean_models User
  end
end
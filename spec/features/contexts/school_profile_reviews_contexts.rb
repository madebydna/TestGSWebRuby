require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'


shared_context 'with 2 questions: first an overall star topic question; second a radio button question' do
  # create topics- requires that a school was set by previous context
  let(:five_star_rating_topic) { FactoryGirl.create(:five_star_rating_topic, school_level: school.level_code, school_type: school.type) }
  let(:teachers_topic) { FactoryGirl.create(:teachers_topic, school_level: school.level_code, school_type: school.type) }
  # create questions for topic
  # Execute immediately
  let!(:five_star_rating_question) { FactoryGirl.create(:five_star_rating_question, review_topic: five_star_rating_topic ) }
  let!(:teacher_question) { FactoryGirl.create(:teacher_question, review_topic: teachers_topic) }

  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'a radio button question' do
  # create topics- requires that a school was set by previous context
  let(:teachers_topic) { FactoryGirl.create(:teachers_topic, school_level: school.level_code, school_type: school.type) }
  # create questions for topic
  # Execute immediately
  let!(:teacher_question) { FactoryGirl.create(:teacher_question, review_topic: teachers_topic) }
  after do
    clean_models ReviewTopic, ReviewQuestion
  end
end

shared_context 'with signing up for a new account' do
  before do
    fill_in(:email, with: 'test@greatschools.org')
    check('terms[terms]')
    click_button('Sign Up')
    current_url
  end
  after do
    clean_models User
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
    current_url
  end
  after do
    clean_models User
  end
end

shared_context 'click third star' do
  before do
    response_option = subject.visible_review_question.stars[2]
    response_option.click
  end
end

shared_context 'select first radio button option' do
 before do
   response_option = subject.visible_review_question.radio_buttons.first
   response_option.click
 end
end

shared_context 'submit response with comment without bad words' do
  before do
    comment = 'lorem ' * 15
    subject.visible_review_question.review_comment.fill_in('review[comment]',with: comment)
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    wait_for_ajax
  end
end

shared_context 'submit response with bad word' do
  before do
    AlertWord.create!( word: 'test_really_bad_word', really_bad: true )
    comment = 'lorem ' * 15 + 'test_really_bad_word'
    subject.visible_review_question.review_comment.fill_in('review[comment]',with: comment)
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    wait_for_ajax
  end
end


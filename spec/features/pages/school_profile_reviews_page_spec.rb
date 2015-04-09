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

shared_context 'Submit Response' do
  before do
    # question_submit = subject.all(:css, '.js-review-question-submit', visible: true).first
    question_submit = subject.visible_review_question.submit_button
    question_submit.click
    sleep (1)
  end
end

shared_context 'sign up for an account' do
  before do
    fill_in(:email, with: 'test@greatschools.org')
    check('terms[terms]')
    click_button('Sign Up')
  end
end


describe 'School Profile Reviews Page', js: true do

  after do
    clean_dbs :gs_schooldb
    clean_models School
  end

  with_shared_context 'Given basic school profile page', 'Reviews' do
    include_context 'with Alameda High School'
    with_shared_context 'Visit School Profile Reviews' do
      include_example 'should be on the correct page'
      it 'should show the review module' do
        expect(subject).to have_review_module
      end
      with_shared_context 'with two topics and questions' do
        it 'should show the first question' do
          expect(subject.review_module).to have_questions
        end
        it 'should not show the review comment form' do
          expect(subject.visible_review_question).not_to have_review_comment
        end

        with_shared_context 'Click Question Response' do
          it 'should show the review comment section' do
            expect(subject.visible_review_question).to have_review_comment
          end

          with_shared_context 'signed in verified user' do
            with_shared_context 'Submit Response' do
              it 'should show next question' do
                expect(subject.visible_review_question.question.text).to eq(review_question2.question)
              end
            end
          end

          describe 'when not signed in' do
            with_shared_context 'Submit Response' do
              it 'should be redirected to the join page' do
                expect(page.current_path).to eq(join_path)
              end
              with_shared_context 'sign up for an account' do
                it 'should be redirected to the reviews page' do
                  expect(SchoolProfileReviewsPage.new).to be_displayed
                end
                it 'should thank the user' do
                  expect(page).to have_content('Thanks for your school review!')
                end
              end
            end
          end

        end
      end
    end
  end
end


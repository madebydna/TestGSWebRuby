require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../contexts/school_profile_reviews_contexts'
require_relative '../examples/page_examples'
require_relative '../examples/school_profile_reviews_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'

shared_context 'with active reviews' do
  before do
    [
        FactoryGirl.create(:review)
    ]

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
      include_example 'should show the review module'

      with_shared_context 'with 2 questions: first an overall star topic question; second a radio button question' do
        include_example 'should show the overall star question'
        include_example 'should show the review comment section'
        with_shared_context 'signed in verified user' do
          with_shared_context 'click third star' do
            with_shared_context 'submit response with comment without bad words' do
              include_example 'should save review with expected value', '3'
              include_example 'should save overall review with comment without bad words'
              include_example 'should save review that is active'
              include_example 'should show next question'
              include_example 'should show a radio_button question'
              include_example 'should not show the review comment form'
            end

            with_shared_context 'submit response with bad word' do
              include_example 'should save review with expected value', '3'
              include_example 'should save overall review with comment with bad words'
              include_example 'should save review that is not active'
              include_example 'should show next question'
              include_example 'should show a radio_button question'
              include_example 'should not show the review comment form'
            end
          end
        end

        describe 'when not signed in' do
          with_shared_context 'click third star' do
            with_shared_context 'submit response with comment without bad words' do
              it 'should be redirected to the join page' do
                expect(page.current_path).to eq(join_path)
              end

              with_shared_context 'with signing into a verified account' do
                include_example 'should be redirected to the reviews page'
                include_example 'should contain the expected text', *['Thanks for your school review! Your feedback helps other parents choose the right schools!']
                include_example 'should save review with expected value', '3'
                include_example 'should save overall review with comment without bad words'
                include_example 'should save review that is active'
              end

              with_shared_context 'with signing up for a new account' do
                include_example 'should be redirected to the reviews page'
                include_example 'should contain the expected text', *["Thank you - we've saved your review. We can publish it once you verify your email address; please check your inbox for an email from us."]
                include_example 'should save review with expected value', '3'
                include_example 'should save overall review with comment without bad words'
                include_example 'should save review that is not active'
              end
            end

            with_shared_context 'submit response with bad word' do
              with_shared_context 'with signing into a verified account' do
                include_example 'should be redirected to the reviews page'
                include_example 'should contain the expected text', *['Please note that it can take up to 48 hours for your review to be posted to our site.']
                include_example 'should save review with expected value', '3'
                include_example 'should save overall review with comment with bad words'
                include_example 'should save review that is not active'
              end
            end
          end
        end
      end
      with_shared_context 'a radio button question' do
        with_shared_context 'signed in verified user' do
          include_example 'should show a radio_button question'
          include_example 'should not show the review comment form'
          with_shared_context 'select first radio button option' do
            include_example 'should show the review comment section'
            with_shared_context 'submit response with comment without bad words' do
              include_example 'should save overall review with comment without bad words'
              include_example 'should save review with expected value', "Very ineffective"
            end
          end
        end
      end

    end

    # with_shared_context 'with reviews' do
    #   with_shared_context 'Visit School Profile Reviews' do

    # end
    # end
  end
end


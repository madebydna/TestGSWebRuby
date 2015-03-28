require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_reviews_page'

describe 'School Profile Reviews Page' do
  include_context 'Visit School Profile Reviews'

  after do
    clean_dbs :gs_schooldb
    clean_models School
  end

  shared_context 'with a topic and question' do
    # create a topic - requires that a school was set by previous context
    let(:topic) { FactoryGirl.create(:review_topic, school_level: school.level_code, school_type: school.type) }
    # create questions for topic
    # Execute immediately
    let!(:review_question) { FactoryGirl.create(:review_question, review_topic: topic)  }
    after do
      clean_models ReviewTopic, ReviewQuestion
    end
  end

  with_shared_context 'Given basic school profile page', 'Reviews' do
    with_shared_context 'with Alameda High School' do
      include_example 'should be on the correct page'

      it 'should show the review module' do
        expect(subject).to have_review_module
      end

      with_shared_context 'with a topic and question' do
        it 'should show the first question' do

          expect(subject.review_module).to have_questions
          # expect(subject.review_module_questions.first).to be_visible
        end
      end
    end
  end


  # with_shared_context 'Given basic school profile page' do
  #   with_shared_context 'with Alameda High School' do
  #     include_example 'should be on the correct page'
  #     expect_it_to_have_element(:profile_navigation)
  #   end
  #
  #   with_shared_context 'with an inactive school' do
  #     it 'should not be on the profile page' do
  #       pending 'TODO: Do not allow profile page to handle inactive school'
  #       fail
  #     end
  #     # include_example 'should be on the correct page'
  #   end
  #
  #   with_shared_context 'with a demo school' do
  #     include_example 'should be on the correct page'
  #     expect_it_to_have_element(:profile_navigation)
  #     include_example 'should have the noindex meta tag'
  #     include_example 'should have the nofollow meta tag'
  #     include_example 'should have the noarchive meta tag'
  #   end
  # end

end


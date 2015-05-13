require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../contexts/school_profile_reviews_contexts'
require_relative '../examples/page_examples'
require_relative '../examples/school_profile_reviews_examples'
require_relative '../pages/school_profile_reviews_page'
require 'support/shared_contexts_for_signed_in_users'

describe 'School Profile Reviews Page', js: true do
  before do
    pending('TODO: Figure out why tests fail intermittently')
    fail
  end

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
        include_example 'should show stars'
        include_example 'should show the review comment section'
        with_shared_context 'signed in verified user' do
          with_shared_context 'click third star' do
            with_shared_context 'submit response with comment without bad words' do
              include_example 'should save review with expected value', '3'
              include_example 'should save overall review with comment without bad words'
              include_example 'should save review that is active'
              include_example 'should show next question'
              include_example 'should show a radio_button question'
              with_subject :visible_review_question do

                it { pending ('fix'); is_expected.to have_call_to_action_text }
              end
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
                with_shared_context 'Visit School Profile Reviews' do
                  include_example 'should show a radio_button question'
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
        with_shared_context 'with signed in as principal for school' do
        include_example 'should show the overall star question'
        include_example 'should not show stars'
        include_example 'should show the review comment section'
        include_example 'should show submit button with principal text'
        with_shared_context 'submit response with comment without bad words' do
          include_example 'should save overall review with comment without bad words'
          include_example 'should show the review comment section'
          # include_example 'should save review that is active'
          include_example 'should show submit button with principal text'
          include_example 'should show next question'
          include_example 'should not show radio buttons'
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

    with_shared_context 'an overall principal review' do
      with_shared_context 'Visit School Profile Reviews' do
        it { is_expected.to have_principal_review }
      end
    end

    with_shared_context 'a topical principal review' do
      with_shared_context 'Visit School Profile Reviews' do
        it { is_expected.to_not have_principal_review }
        with_subject :first_review do
          it { is_expected.to be_school_leader_review }
        end
      end
    end

    with_shared_context 'with two active reviews' do
      with_shared_context 'signed in verified user' do
        with_shared_context 'with seven parent reviews' do
          include_context 'with seven student reviews'
          with_shared_context 'Visit School Profile Reviews' do
            with_subject :reviews do
              its(:size) { is_expected.to eq(10) }
            end

            when_I :filter_by_parents do
              with_subject :reviews do
                it 'shows only parent reviews' do
                  page_object.wait_for_reviews
                  subject.each do |review|
                    expect(review).to be_parent_review
                  end
                end
              end
            end

            when_I :filter_by_students do
              with_subject :reviews do
                it 'shows only student reviews' do
                  page_object.wait_for_reviews
                  subject.each do |review|
                    expect(review).to be_student_review
                  end
                end
              end
            end
          end
        end

        with_shared_context 'Visit School Profile Reviews' do
          it { is_expected.to have_reviews }
          it { is_expected.to have_reviews_list_header }

          with_subject :reviews do
            they { are_expected.to have_posted }
            they { are_expected.to have_flag_review_link }

            with_subject :first_review do
              on_subject :click_on_flag_review_link do
                it { is_expected.to have_flag_review_form }

                on_subject :submit_review_flag_comment, 'I hate this review' do
                  it 'should be saved to the database' do
                    wait_for_page_to_finish
                    flag = ReviewFlag.last
                    expect(flag).to be_present
                    expect(flag.comment).to eq('I hate this review')
                    expect(flag.review_id).to eq(two_active_reviews.first.id)
                  end
                end
              end
            end
          end


          with_subject :review_dates do
            it { is_expected.to be_in_descending_order }
          end

          with_subject :review_values do
            it 'should have the topic label' do
              subject.each_with_index do |review_value, index|
                topic_label = two_active_reviews[index].question.review_topic.label
                if topic_label == 'Overall experience'
                  expect(review_value).to_not have_content(topic_label)
                else
                  expect(review_value).to have_content(topic_label)
                end
              end
            end
          end
        end

        with_shared_context 'with inactive review' do
          with_shared_context 'Visit School Profile Reviews' do
            with_subject :reviews do
              its(:size) { is_expected.to eq(2) }
              they { are_expected.to_not have_content 'inactive review' }
            end
          end
        end
      end
    end
  end
end


require 'spec_helper'
require 'features/contexts/school_profile_contexts'
require 'features/contexts/school_profile_reviews_contexts'
require 'features/examples/page_examples'
require 'features/examples/school_profile_reviews_examples'
require 'features/page_objects/school_profile_reviews_page'
require 'features/contexts/shared_contexts_for_signed_in_users'
require 'features/examples/footer_examples'

describe 'School Profile Reviews Page' do
  before do
    # pending('TODO: Figure out why tests fail intermittently')
    # fail
  end

  after do
    clean_dbs :gs_schooldb
    clean_models School
  end

  let(:overall_rating_question_text) { FactoryGirl.build(:overall_rating_question).question }
  let(:overall_rating_principal_question_text) { FactoryGirl.build(:overall_rating_question).principal_question }

  with_shared_context 'Given basic school profile page', 'Reviews' do
    with_shared_context 'with Cristo Rey New York High School' do
      with_shared_context 'Visit School Profile Reviews' do
        include_example 'should be on the correct page'
        it { is_expected.to have_review_module }
      end
    end
  end

  with_shared_context 'Given basic school profile page', 'Reviews', js: true  do
    include_context 'with Alameda High School'
    with_shared_context 'Visit School Profile Reviews' do
      include_examples 'should have a footer'
      include_example 'should be on the correct page'
      it { is_expected.to have_review_module }

      with_shared_context 'with 2 questions: first an overall star topic question; second a radio button question' do
        with_subject :review_module do
          its(:first_slide) { is_expected.to be_active }
          its(:active_slide) { is_expected.to have_stars }
          its(:active_slide) { is_expected.to have_overall_summary }
          its('active_slide.text') { is_expected.to include(overall_rating_question_text) }
        end

        with_shared_context 'signed in verified user with role for school' do
          with_shared_context 'click third star' do
            its('active_slide.review_comment') { is_expected.to be_visible }
            when_I :submit_a_comment do
              before do
                pending 'Slides dont change upon submitting comment. Reason unknown'
              end
              its('review_module.first_slide') { is_expected.to_not be_active }
              its('review_module.second_slide') { is_expected.to be_active }
              its(:active_slide) { is_expected.to have_radio_buttons }
              its(:active_slide) { is_expected.to_not have_review_comment }
            end
          end
        end

        describe 'when not signed in' do
          when_I :click_third_star do
            when_I :submit_a_comment do
              with_shared_context 'with signing into a verified account without role for school' do
                include_example 'should contain the expected text', *['Thanks for your school review! Your feedback helps other parents choose the right schools!']
                it { is_expected.to have_role_question }
                with_shared_context 'select parent role' do
                  its(:active_slide) { is_expected.to have_radio_buttons }
                end
              end

              with_shared_context 'with signing into a verified account with role for school' do
                include_example 'should contain the expected text', *['Thanks for your school review! Your feedback helps other parents choose the right schools!']
                it { is_expected.to_not have_role_question }
                its(:active_slide) { is_expected.to have_radio_buttons }
              end

              with_shared_context 'with signing up for a new account' do
                include_example 'should contain the expected text', *["Thank you - we've saved your review. We can publish it once you verify your email address; please check your inbox for an email from us."]
                with_shared_context 'Visit School Profile Reviews' do
                  with_shared_context 'select parent role' do
                  its(:active_slide) { is_expected.to have_radio_buttons }
                  end
                end
              end
            end

          end
        end

        with_shared_context 'with signed in as principal for school' do
          it { is_expected.to have_review_module }

          with_subject :review_module do
            its(:first_slide) { is_expected.to be_active }
            its(:second_slide) { is_expected.to_not be_active }
          end

          with_subject :active_slide do
            its(:text) { is_expected.to_not include(overall_rating_question_text) }
            its(:text) { is_expected.to include(overall_rating_principal_question_text) }
            it { is_expected.to_not have_stars }
          end

          # TODO: Check for submit button with principal text

          when_I :submit_a_comment do
            with_subject :review_module do
              # TODO: why cant we test that slide 2 is active now?
              # its(:first_slide) { is_expected.to_not be_active }
              # its(:second_slide) { is_expected.to be_active }
              its(:first_slide) { is_expected.to have_review_comment }
            end
          end
        end
      end

      with_shared_context 'a radio button question' do
        with_shared_context 'signed in verified user' do
          its(:active_slide) { is_expected.to have_radio_buttons }
          its('active_slide.review_comment') { is_expected.to_not be_visible }
          with_shared_context 'select first radio button option' do
            its('active_slide.review_comment') { is_expected.to be_visible }
            # when_I :submit_a_comment do
              before { pending 'Legitimate bug'; fail; }
              it { is_expected.to have_role_question }
            # end
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

    with_shared_context 'with active review' do
      with_shared_context 'Visit School Profile Reviews' do
        with_subject :first_review do
          it { is_expected.to have_vote_for_review_button }
          when_I :vote_on_the_first_review do
            with_shared_context 'with signing up for a new account' do
              with_subject :first_review do
                it { is_expected.to have_number_of_votes }
                its(:number_of_votes_text) { is_expected.to match /1 person/ }
                when_I :unvote_the_first_review do
                  it { is_expected.to_not have_unvote_review_button }
                  it { is_expected.to have_vote_for_review_button }
                  its(:number_of_votes_text) { is_expected.to be_empty }
                end
              end
            end
          end
        end
      end
    end

    with_shared_context 'with active review with one vote' do
      with_shared_context 'Visit School Profile Reviews' do
        with_subject :first_review do
          it { is_expected.to have_vote_for_review_button }
          it { is_expected.to_not have_unvote_review_button }
          when_I :vote_on_the_first_review do
            with_shared_context 'with signing up for a new account' do
              with_subject :first_review do
                it { is_expected.to have_number_of_votes }
                it { is_expected.to have_unvote_review_button }
                its(:number_of_votes_text) { is_expected.to match /2 people/ }
                when_I :unvote_the_first_review do
                  it { is_expected.to_not have_unvote_review_button }
                  it { is_expected.to have_vote_for_review_button }
                  it { is_expected.to have_number_of_votes }
                  its(:number_of_votes_text) { is_expected.to match /1 person/ }
                end
              end
            end
          end
        end
      end

      with_shared_context 'signed in verified user' do
        with_shared_context 'Visit School Profile Reviews' do
          with_subject :first_review do
            when_I :vote_on_the_first_review do
              with_subject :first_review do
                it { is_expected.to have_number_of_votes }
                its(:number_of_votes_text) { is_expected.to match /2 people/ }
                when_I :unvote_the_first_review do
                  it { is_expected.to have_number_of_votes }
                  its(:number_of_votes_text) { is_expected.to match /1 person/ }
                end
              end
            end
          end
        end
      end
    end

    with_shared_context 'with seven parent overall reviews' do
      include_context 'with seven student teacher effectiveness reviews'
      with_shared_context 'signed in verified user' do
        with_shared_context 'Visit School Profile Reviews' do
          it { is_expected.to have_reviews }
          it { is_expected.to have_reviews_list_header }

          with_subject :reviews do
            its(:size) { is_expected.to eq(10) }
          end

          with_subject :reviews_list_header do
            it { is_expected.to have_reviews_topic_filter_button }
            include_example 'should have reviews filter with default All topics'
          end

          when_I :filter_by_overall_topic do
            with_subject :reviews do
              it 'shows only overall reviews' do
                page_object.wait_for_reviews
                subject.each do |review|
                  expect(review).to be_overall_review
                end
              end
            end
          end

          when_I :filter_by_teachers_topic do
            with_subject :reviews do
              it 'shows only teachers reviews' do
                page_object.wait_for_reviews
                subject.each do |review|
                  expect(review).to be_teacher_effectiveness_review
                end
              end
            end
          end
        end
      end
    end
  end
end


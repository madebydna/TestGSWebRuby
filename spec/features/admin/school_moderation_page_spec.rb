require 'spec_helper'
require 'features/pages/admin/school_moderation_page'

shared_context 'visit page' do |page_class, *args|
  let(:page_object) { page_class.new }
  before { page_object.load(*args) }
  subject { page_object }
end

shared_context 'flagged reviews' do
  let!(:user) { FactoryGirl.create(:verified_user) }
  let!(:review) { FactoryGirl.create(:five_star_review, :flagged, user: user, school: school, answer_value: 'Agree') }
  after do
    clean_dbs :gs_schooldb, :surveys, :community
  end
end

shared_context 'alameda high school' do |state, school_id|
  let!(:school) { FactoryGirl.create(:alameda_high_school, state: state, id: school_id) }
  after do
    clean_models School
  end
end

describe 'School moderate page' do
  state = 'CA'
  school_id = '1'
  state_name = States.state_name(state)

  with_shared_context 'alameda high school', state, school_id do
    with_shared_context 'visit page', SchoolModerationPage, state: state_name, school_id: school_id do

      it { is_expected.to be_displayed }
      it { is_expected.to have_content school.name }
      it { is_expected.to have_school_search_form }
      it { is_expected.to have_held_school_module }

      with_subject :held_school_module do
        after { clean_models HeldSchool }

        it { is_expected.to_not be_on_hold }

        when_I :submit_a_school_note, 'Some notes' do
          with_subject :held_school_module do
            it { is_expected.to be_on_hold }
            its(:notes_box) { is_expected.to have_content 'Some notes' }

            when_I :remove_school_held_status do
              it { is_expected.to_not be_on_hold }
              it 'notes box should be blank' do
                expect(subject.notes_box.value).to be_blank
              end
            end
          end
        end
      end
    end

    with_shared_context 'visit page', SchoolModerationPage, state: state_name, school_id: school_id do
      when_I 'search for school', 'CA', 99999 do
        it { is_expected.to have_content 'School not found' }
      end
    end

    with_shared_context 'flagged reviews' do
      with_shared_context 'visit page', SchoolModerationPage, state: state_name, school_id: school_id do
        when_I 'search for school', state, school_id do
          it { is_expected.to have_content school.name }
          it { is_expected.to have_reviews }

          with_subject :the_first_review do
            it { is_expected.to have_comment }
            it { is_expected.to have_content review.comment }
            it { is_expected.to have_content review.user.email }
            it { is_expected.to be_active }
            it { is_expected.to have_deactivate_button }
            it { is_expected.to have_resolve_flags_button }
            it { is_expected.to have_flag_review_button }
            it { is_expected.to have_notes_box }
            it { is_expected.to have_save_notes_button }
            it { is_expected.to have_review_answer }
            it { is_expected.to have_review_topic }

            it { is_expected.to have_open_flags }
            it { is_expected.to_not have_resolved_flags }

            with_subject :the_first_open_flag do
              its(:reason) { is_expected.to have_content(review.flags.first.reason) }
              its(:flagged_on) { is_expected.to have_content(review.flags.first.created.strftime('%B %d, %Y') ) }
              its(:flagged_by) { is_expected.to have_content(review.flags.first.user.email ) }
              its(:comment) { is_expected.to have_content(review.flags.first.comment) }
            end

            when_I :click_on_the_resolve_flags_button do
              with_subject 'the first review' do
                it { is_expected.to_not have_open_flags }
                it { is_expected.to have_resolved_flags }
              end
            end

            when_I :click_on_the_deactivate_review_button do
              with_subject 'the first review' do
                it { is_expected.to_not have_deactivate_button }
                it { is_expected.to have_activate_button }
                it { is_expected.to be_inactive }
              end
            end

            when_I :submit_a_review_note, 'a test note' do
              with_subject 'the first review' do
                it { is_expected.to have_content 'a test note' }
              end
            end
          end

        end
      end
    end
  end
end
require 'spec_helper'
require 'features/pages/admin/school_moderation_page'

shared_context 'search for school' do |state, id|
  before do
    form = page_object.school_search_form
    form.state_dropdown.select(state)
    form.school_id_box.set(id)
    form.search_button.click
  end
end

shared_context 'visit school moderation page' do |state, school_id|
  before do
    visit admin_school_moderate_path(state: States.state_name(state), school_id: school_id)
  end
end

describe 'School moderate page' do
  state = 'CA'
  school_id = '1'
  let(:page_object) do
    SchoolModerationPage.new
  end
  subject { page_object }

  context 'with alameda high school' do
    let!(:school) { FactoryGirl.create(:alameda_high_school, state: state, id: school_id) }
    include_context 'visit school moderation page', state, school_id

    after do
      clean_models School
    end

    it { is_expected.to be_displayed }
    it { is_expected.to have_content school.name }
    it { is_expected.to have_school_search_form }
    it { is_expected.to have_held_school_module }

    describe 'held school behavior' do
      subject { page_object.held_school_module }
      after do
        clean_models HeldSchool
      end

      it { is_expected.to have_content 'School not on hold' }

      context 'when placing a school on hold with notes' do
        before do
          page_object.held_school_module.notes_box.set('Some notes')
          page_object.held_school_module.submit_button.click
        end
        subject { SchoolModerationPage.new.held_school_module }
        it { is_expected.to have_content 'School on hold'}
        it 'notes box should have "Some notes"' do
          expect(subject.notes_box).to have_content 'Some notes'
        end

        context 'when removing the held status' do
          before do
            SchoolModerationPage.new.held_school_module.remove_held_status_button.click
          end
          it { is_expected.to have_content 'School not on hold'}
          it 'notes box should not have content' do
            expect(subject.notes_box.value).to be_blank
          end
        end
      end
    end

    with_shared_context 'search for school', 'CA', 99999 do
      it { is_expected.to have_content 'School not found' }
    end

    with_shared_context 'search for school', state, school_id do
      context 'with flagged reviews' do
        let!(:user) { FactoryGirl.create(:verified_user) }
        let!(:review) { FactoryGirl.create(:school_rating, :flagged, user: user, school: school) }
        after do
          clean_dbs :gs_schooldb, :surveys, :community
        end

        with_shared_context 'visit school moderation page', state, school_id do
          it { is_expected.to have_content school.name }
          it { is_expected.to have_reviews }

          describe 'the specific review' do
            subject { page_object.reviews.first }

            it { is_expected.to have_comment }
            it { is_expected.to have_content review.comments }
            it { is_expected.to have_content review.user.email }

            describe 'notes' do
              it { is_expected.to have_notes_box }
              it { is_expected.to have_save_notes_button }

              context 'when submitting a new note' do
                before do
                  page_object.reviews.first.notes_box.set('Here is a test note')
                  page_object.reviews.first.save_notes_button.click
                end
                subject { SchoolModerationPage.new.reviews.first.notes_box }
                # We need a new SchoolModeratePage as the subject, since the page has been reloaded
                it { is_expected.to have_content 'Here is a test note' }
              end
            end
          end
        end
      end
    end
  end
end
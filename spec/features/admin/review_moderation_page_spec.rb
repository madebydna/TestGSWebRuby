require 'spec_helper'
require 'features/pages/admin/review_moderation_page'


shared_context 'visit the review moderation page' do
  before do
    visit moderation_admin_reviews_path
  end
end

describe 'Review moderation page' do

  # let!(:school) { FactoryGirl.create(:alameda_high_school) }
  let(:page_object) { ReviewModerationPage.new }
  subject { page_object }

  context 'when there are flagged reviews' do
    let!(:user) { FactoryGirl.create(:verified_user) }
    let!(:school) { FactoryGirl.create(:alameda_high_school) }
    let!(:reviews) { FactoryGirl.create_list(:review, 3, :flagged, school: school, user: user) }
    before do
    end
    after do
      clean_dbs :surveys, :gs_schooldb, :community
      clean_models School
    end

    with_shared_context 'visit the review moderation page' do
      it 'should be on the right page' do
        expect(subject).to be_displayed
      end

      it 'should show the header' do
        expect(subject).to have_content 'Reviews moderation list'
      end

      describe 'the list of reviews', js: true do
        subject { page_object.flagged_reviews_table }
        it 'should have one review' do
          expect(subject.reviews.size).to eq(3)
        end

        describe 'each flagged review' do
          subject { page_object.flagged_reviews_table.reviews }

          3.times do |index|
            describe "#{(index+1).ordinalize} review" do
              subject { page_object.flagged_reviews_table.reviews[index] }

              it 'should list the school name' do
                expect(subject.school_name).to have_content(school.name)
              end
              it 'shows the first 17 characters of review plus ellipsis' do
                expect(subject.comment).to have_content "#{reviews[index].comment[0..16]}..."
              end
            end
          end
        end
      end
    end

  end

end
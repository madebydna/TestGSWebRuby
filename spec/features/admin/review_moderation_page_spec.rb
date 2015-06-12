require 'spec_helper'
require 'features/pages/admin/review_moderation_page'


shared_context 'visit the review moderation page' do
  before do
    visit moderation_admin_reviews_path
  end
end

shared_context 'with a review flagged because of' do |reason|
  before do
    FactoryGirl.create(:review, :flagged, review_flag_reason: reason)
  end
  after do
    clean_dbs :gs_schooldb
    clean_models School
  end
end

shared_context 'when I filter on' do |reason|
  before do
    page_object.reason_filters.filter_on(reason)
  end
end

shared_context 'with three inactive reviews' do
  let!(:user) { FactoryGirl.create(:verified_user) }
  let!(:school) { FactoryGirl.create(:alameda_high_school) }
  let!(:reviews) { FactoryGirl.create_list(:review, 3, :flagged, school: school, user: user) }
  before do
    reviews.each do |review|
      review.moderated = true
      review.deactivate
      review.question = ReviewQuestion.first
      review.save
    end
  end
  after do
    clean_dbs :surveys, :gs_schooldb, :community
    clean_models School
  end
end

describe 'Review moderation page' do

  let(:page_object) { ReviewModerationPage.new }
  subject { page_object }

  with_shared_context 'with three inactive reviews' do
    with_shared_context 'visit the review moderation page' do
      with_subject :flagged_reviews_table do
        it 'should show only one review' do
          expect(subject.reviews.size).to eq(1)
        end
      end
    end
  end

  context 'when there are flagged reviews' do
    let!(:user) { FactoryGirl.create(:verified_user) }
    let!(:school) { FactoryGirl.create(:alameda_high_school) }
    let!(:reviews) { FactoryGirl.create_list(:review, 3, :flagged, school: school, user: user) }
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

      it { is_expected.to have_reason_filters }

      with_shared_context 'with a review flagged because of', ReviewFlag::STUDENT, js: true do
        include_context 'with a review flagged because of', ReviewFlag::BAD_LANGUAGE
        with_shared_context 'visit the review moderation page' do
          [ReviewFlag::STUDENT, ReviewFlag::BAD_LANGUAGE].each do |reason|
            with_shared_context 'when I filter on', reason do
              describe 'each flagged review' do
                subject { page_object.flagged_reviews_table.reviews }
                it "should have reason #{reason}" do
                  subject.each do |item|
                    expect(item.reason.text).to eq(reason.to_s)
                  end
                end
              end
            end
          end
        end
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
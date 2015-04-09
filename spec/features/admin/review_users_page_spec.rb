require 'spec_helper'
require 'features/pages/admin/review_users_page'

describe 'Review users page' do

  let(:page_object) { ReviewUsersPage.new }
  subject do
    visit users_admin_reviews_path
    page_object
  end

  it 'should be on the right page' do
    expect(subject).to be_displayed
  end

  it 'should have the search by email or IP form' do
    expect(subject).to have_find_by_email_or_ip_form
  end

  describe 'Searching by email or IP' do
    context 'with an email for a user with flagged reviews' do
      before do
        subject.find_by_email_or_ip_form.search_box.set('blah@greatschools.org')
        subject.find_by_email_or_ip_form.search_button.click
      end

      it 'Should show an empty list of reviews' do
        expect(subject).to have_flagged_reviews_table
        expect(subject.flagged_reviews_table.flagged_reviews).to be_empty
      end
    end

    context 'with an email for a user with flagged reviews' do
      let(:user) { FactoryGirl.create(:verified_user) }
      let!(:reviews) { FactoryGirl.create_list(:school_rating, 2, :flagged, user: user) }
      before do
        subject.find_by_email_or_ip_form.search_box.set(user.email)
        subject.find_by_email_or_ip_form.search_button.click
      end

      after do
        clean_dbs :gs_schooldb, :surveys, :community
      end

      it 'Should show an empty list of reviews' do
        expect(subject).to have_flagged_reviews_table
        expect(subject.flagged_reviews_table.flagged_reviews.size).to eq(2)
      end
    end
  end
end
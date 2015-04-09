require 'spec_helper'
require 'features/pages/admin/review_users_page'

describe 'Review users page' do

  # let!(:school) { FactoryGirl.create(:alameda_high_school) }
  let(:page_object) { ReviewUsersPage.new }
  before do
  end
  subject do
    visit users_admin_reviews_path
    page_object
  end
  after do
  end

  it 'should be on the right page' do
    expect(subject).to be_displayed
  end

  # it 'should show the school name' do
  #   expect(subject).to have_content 'Reviews moderation list'
  # end

end
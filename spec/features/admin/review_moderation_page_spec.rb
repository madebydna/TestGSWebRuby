require 'spec_helper'
require 'features/pages/admin/review_moderation_page'

describe 'Review moderation page' do

  # let!(:school) { FactoryGirl.create(:alameda_high_school) }
  let(:page_object) { ReviewModerationPage.new }
  before do
  end
  subject do
    visit moderation_admin_reviews_path
    page_object
  end
  after do
  end

  it 'should be on the right page' do
    expect(subject).to be_displayed
  end

  it 'should show the header' do
    expect(subject).to have_content 'Reviews moderation list'
  end

end
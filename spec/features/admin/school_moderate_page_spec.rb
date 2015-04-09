require 'spec_helper'
require 'features/pages/admin/school_moderate_page'

describe 'School moderate page' do

  let!(:school) { FactoryGirl.create(:alameda_high_school) }
  let(:page_object) { SchoolModeratePage.new }
  before do
  end
  subject do
    visit admin_school_moderate_path(state: States.state_name(school.state), school_id: school.id)
    page_object
  end
  after do
    clean_models School
  end

  it 'should be on the right page' do
    expect(subject).to be_displayed
  end

  it 'should show the school name' do
    expect(subject).to have_content school.name
  end

end
require 'spec_helper'
require 'features/shared/state_footer_features'

shared_examples 'school profile page' do
  let(:school) { FactoryGirl.create(:alameda_high_school) }
  subject do
    visit school_path(school)
    page
  end
  after do
    clean_models School
  end

  it_behaves_like 'page with state footer features', { short: 'CA', long: 'California' }
end
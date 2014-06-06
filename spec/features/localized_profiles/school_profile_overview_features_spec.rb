require 'spec_helper'
require 'features/localized_profiles/school_profile_features_spec'

feature 'School profile overview page' do
  let!(:profile_page) { FactoryGirl.create(:page, name: 'Overview') }
  after do
    clean_models Page
  end

  it_behaves_like 'school profile page', 'Overview'

  feature 'breadcrumbs' do
    context 'when on a washington, dc profile page' do
      let(:school) do
        FactoryGirl.create(:washington_dc_ps_head_start)
      end
      subject do
        visit school_path(school)
        page
      end
      after do
        clean_models School
      end
      scenario 'State and city breadcrumbs says "/ District of Columbia / Washington, D.C."' do
        expect(subject).to have_content '/ District of Columbia / Washington, D.C.'
      end
    end

    context 'when on a san francisco, ca profile page' do
      let(:school) do
        FactoryGirl.create(:south_san_francisco_high_school)
      end
      subject do
        visit school_path(school)
        page
      end
      after do
        clean_models School
      end
      scenario 'State and city breadcrumbs says "/ California / San Francisco"' do
        expect(subject).to have_content '/ California / San Francisco'
      end
    end
  end
end

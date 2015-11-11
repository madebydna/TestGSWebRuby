require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_overview_page'

shared_context 'with an inactive school' do
  let!(:school) { FactoryGirl.create(:alameda_high_school, active: false) }
end

shared_context 'with a demo school' do
  let!(:school) { FactoryGirl.create(:demo_school, name: 'A demo school') }
end

def expect_it_to_have_element(element)
  proc = Proc.new do
    it "should have the #{element} element" do
      instance_eval("expect(subject).to have_#{element}")
    end
  end
  instance_exec(&proc)
end


describe 'School Profile Overview Page' do
  include_context 'Visit School Profile Overview'

  after do
    clean_dbs :gs_schooldb, :ca
    clean_dbs :profile_config
    clean_models School
  end

  with_shared_context 'Given school profile page with GS Rating Snapshot module' do
    with_shared_context 'with Alameda High School', js: true do
      context 'when configured to get GS rating from school cache' do
        before do
          # FactoryGirl.create(:cached_gs_rating, school_id: school.id, state: school.state)
          # Create an instance of SchoolProfileConfiguration that
          # says "data_type_id": 174 instead of "use_gs_rating": "true"
          # See JT-126
        end
      end
      context 'when configured to get GS rating from school metadata' do
        before do
          FactoryGirl.create(:school_metadata_gs_rating_configuration)
          FactoryGirl.create(:school_metadata, school_id: school.id, meta_key: 'overallRating', meta_value: 10)
        end
        describe 'gs rating' do
          it { is_expected.to have_large_gs_rating }
          its("large_gs_rating.rating_value") { is_expected.to eq('10') }
        end
      end
    end
  end

  with_shared_context 'Given basic school profile page' do
    with_shared_context 'with Alameda High School', js: true do
      include_example 'should be on the correct page'
      expect_it_to_have_element(:profile_navigation)

      its(:header) { is_expected.to_not have_in_english_link }
      its(:header) { is_expected.to have_in_spanish_link }
      context 'switch to spanish' do
        before { page_object.header.switch_to_spanish }
        its(:header) { is_expected.to have_in_english_link }
        context 'switch to english' do
          before { page_object.header.switch_to_english }
          its(:header) { is_expected.to have_in_spanish_link }
        end
      end

      describe 'breadcrumbs' do
        it { is_expected.to have_breadcrumbs }
        its('first_breadcrumb.title') { is_expected.to have_text('California') }
        its('first_breadcrumb') { is_expected.to have_link('California', href: "http://localhost:3001/california/") }
        its('second_breadcrumb.title') { is_expected.to have_text('Alameda') }
        its('second_breadcrumb') { is_expected.to have_link('Alameda', href: "http://localhost:3001/california/alameda/") }
        its('third_breadcrumb.title') { is_expected.to have_text('Schools') }
        its('third_breadcrumb') { is_expected.to have_link('Schools', href: "http://localhost:3001/california/alameda/schools/") }
        its('fourth_breadcrumb.title') { is_expected.to have_text('Alameda High School') }
        its('fourth_breadcrumb') { is_expected.to have_link('Alameda High School', subject.current_url) }
        its('fourth_breadcrumb') { is_expected.to have_breadcrumb_link }
      end
    end

    with_shared_context 'with an inactive school' do
      it 'should not be on the profile page' do
        pending 'TODO: Do not allow profile page to handle inactive school'
        fail
      end
      # include_example 'should be on the correct page'
    end

    with_shared_context 'with a demo school' do
      include_example 'should be on the correct page'
      expect_it_to_have_element(:profile_navigation)
      include_example 'should have the noindex meta tag'
      include_example 'should have the nofollow meta tag'
      include_example 'should have the noarchive meta tag'
    end
  end

end


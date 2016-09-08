require 'spec_helper'
require 'features/contexts/school_profile_contexts'
require 'features/examples/page_examples'
require 'features/page_objects/school_profile_overview_page'
require 'features/page_objects/school_profile_reviews_page'
require 'features/page_objects/school_profile_quality_page'
require 'features/examples/school_profile_header_examples'
require 'features/examples/footer_examples'

shared_context 'with an inactive school' do
  let!(:school) { FactoryGirl.create(:alameda_high_school, active: false, new_profile_school: 0) }
end

shared_context 'with a demo school' do
  let!(:school) { FactoryGirl.create(:demo_school, name: 'A demo school', new_profile_school: 0) }
end

def expect_it_to_have_element(element)
  proc = Proc.new do
    it "should have the #{element} element" do
      instance_eval("expect(subject).to have_#{element}")
    end
  end
  instance_exec(&proc)
end

RSpec::Matchers.define :have_link_with do |text, hash|
  match do |actual|
    l = page.find_link(text)
    l && l['href'].include?(hash[:href])
  end
end

def create_reviews(count, school)
  FactoryGirl.create_list(
    :five_star_review,
    count,
    school_id: school.id,
    state: school.state
  )
end

describe 'School Profile Overview Page' do
  include_context 'Visit School Profile Overview'

  after do
    clean_dbs :gs_schooldb, :ca
    clean_dbs :profile_config
    clean_models School
  end

  with_shared_context 'Given school profile page with GS Rating Snapshot module' do
    with_shared_context 'with Alameda High School' do
      context 'when configured to get GS rating from school cache' do
        before do
          FactoryGirl.create(:school_cache_gs_rating_configuration)
          FactoryGirl.create(:cached_gs_rating, school_id: school.id, state: school.state)
        end
        describe 'gs rating' do
          before do
            FactoryGirl.create(:page, name: 'Quality')
            pending
            fail
          end
          it { is_expected.to have_large_gs_rating }
          its("large_gs_rating.rating_value") { is_expected.to eq('5') } # 5 is hardcoded in factory for now
          when_I :click_on_large_gs_rating , js:true do
            it 'should go to the quality page' do
              expect(SchoolProfileQualityPage.new).to be_displayed
            end
          end
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

  with_shared_context 'Given school profile page with Reviews Snapshot module' do
    with_shared_context 'with Alameda High School', js: true do
      before { pending('failing most likely because of this commit: f9b453c'); fail }
      when_I :click_on_write_a_review_button do
        before do
          FactoryGirl.create(:page, name: 'Reviews')
          fail
        end
        it 'should go to the reviews page' do
          expect(SchoolProfileReviewsPage.new).to be_displayed
        end
      end
    end
  end

  with_shared_context 'Given basic school profile page' do
    with_shared_context 'with Alameda High School' do
      include_example 'should be on the correct page'
      it_behaves_like 'a page with school profile header'
      include_examples 'should have a footer'

      describe 'language switching', js:true do
        before do
          page_object.header.wait_for_in_spanish_link
        end
        its(:header) { is_expected.to_not have_in_english_link }
        its(:header) { is_expected.to have_in_spanish_link }
        context 'switch to spanish', js: true do
          before { page_object.header.switch_to_spanish }
          its(:header) { is_expected.to have_in_english_link }
          context 'switch to english' do
            before { page_object.header.switch_to_english }
            its(:header) { is_expected.to have_in_spanish_link }
          end
        end
      end


      describe 'breadcrumbs' do
        it { is_expected.to have_breadcrumbs }
        its('first_breadcrumb.title') { is_expected.to have_text('California') }
        its('first_breadcrumb') { is_expected.to have_link_with('California', href: '/california/') }
        its('second_breadcrumb.title') { is_expected.to have_text('Alameda') }
        its('second_breadcrumb') { is_expected.to have_link_with('Alameda', href: '/california/alameda/') }
        its('third_breadcrumb.title') { is_expected.to have_text('Schools') }
        its('third_breadcrumb') { is_expected.to have_link_with('Schools', href: '/california/alameda/schools/') }
        its('fourth_breadcrumb.title') { is_expected.to have_text('Alameda High School') }
        its('fourth_breadcrumb') { is_expected.to have_link_with('Alameda High School', href: subject.current_path) }
        its('fourth_breadcrumb') { is_expected.to have_breadcrumb_link }

        with_shared_context 'with a Washington, DC school' do
          its('first_breadcrumb.title') { is_expected.to have_text('District of Columbia') }
          its('first_breadcrumb') { is_expected.to have_link_with('District of Columbia', href: '/washington-dc/') }
          its('second_breadcrumb.title') { is_expected.to have_text('Washington, D.C.') }
          its('second_breadcrumb') { is_expected.to have_link_with('Washington, D.C.', href: '/washington-dc/washington/') }
          its('third_breadcrumb.title') { is_expected.to have_text('Schools') }
          its('third_breadcrumb') { is_expected.to have_link_with('Schools', href: '/washington-dc/washington/schools/') }
          its('fourth_breadcrumb.title') { is_expected.to have_text('Washington Dc Ps Head Start') }
          its('fourth_breadcrumb') { is_expected.to have_link_with('Washington Dc Ps Head Start', href: subject.current_path) }
          its('fourth_breadcrumb') { is_expected.to have_breadcrumb_link }
        end
      end
    end

    with_shared_context 'with an inactive school' do
      it 'should not be on the profile page' do
        pending 'TODO: Do not allow profile page to handle inactive school'
        fail
      end
      # include_example 'should be on the correct page'
    end

    with_shared_context 'with Cristo Rey New York High School' do
      include_example 'should be on the correct page'
      it_behaves_like 'a page with school profile header'
    end

    with_shared_context 'with a demo school' do
      include_example 'should be on the correct page'
      it_behaves_like 'a page with school profile header'
      include_example 'should have the noindex meta tag'
      include_example 'should have the nofollow meta tag'
      include_example 'should have the noarchive meta tag'
    end


  end

  with_shared_context 'Given school profile page with school test guide module' do
   with_shared_context 'with elementary school in CA' do
      include_example 'should be on the correct page'
      it 'should have the SBAC score report link' do
        subject
        link = page.find_link('SBAC score report')
        expect(link['href']).to include('/gk/common-core-test-guide')
      end
   end
   with_shared_context 'with Cristo Rey New York High School' do
      include_example 'should be on the correct page'
      it { is_expected.to_not have_link('SBAC score report') }
   end
   with_shared_context 'with Cesar Chavez Academy Denver' do
      include_example 'should be on the correct page'
      it 'should have the SBAC score report link' do
        subject
        link = page.find_link('PARCC score report')
        expect(link['href']).to include('/gk/common-core-test-guide')
      end
   end
  end

  describe 'reviews section' do
    include_context 'Given school profile page with reviews section on overview'
    include_context 'with Alameda High School'

    it { is_expected.to have_reviews_section }

    with_subject :reviews_section do
      it { is_expected.to have_ad_slot }
      context 'with no reviews' do
        it { is_expected.to_not have_bar_chart }
        it { is_expected.to_not have_reviews }
        it { is_expected.to have_callout_text }
        it { is_expected.to have_callout_button }
        on_subject :show, js:true do
          when_I :close_all_modals do
            when_I :click_on_callout_button do
              it { expect(SchoolProfileReviewsPage.new).to be_displayed }
            end
          end
        end
      end
      context 'with less than max # of reviews on overview' do
        before { create_reviews(DeprecatedSchoolProfileController::MAX_NUMBER_OF_REVIEWS_ON_OVERVIEW - 1, school) }
        it { is_expected.to have_bar_chart }
        it { is_expected.to have_reviews }
        it { is_expected.to have_callout_text }
        it { is_expected.to have_callout_button }
      end
      context 'with max # of reviews on overview' do
        before { create_reviews(DeprecatedSchoolProfileController::MAX_NUMBER_OF_REVIEWS_ON_OVERVIEW, school) }
        it { is_expected.to have_bar_chart }
        it { is_expected.to have_reviews }
        it { is_expected.to_not have_callout_text }
        it { is_expected.to_not have_callout_button }
      end
    end
  end

  describe 'Contact this school' do
    include_context 'Given school profile page with Contact this school section'
    include_context 'with Alameda High School'

    it { is_expected.to have_contact_this_school_header }
    it { is_expected.to have_contact_this_school_content }
    it { is_expected.to have_contact_this_school_map_section }
    its(:contact_this_school_content) { is_expected.to have_text(school.city+', '+school.state) }
    its(:contact_this_school_content) { is_expected.to have_link('Nearby homes for sale') }
    its(:contact_this_school_map_section) { is_expected.to have_school_map }

  end

  describe 'media gallery' do
    include_context 'Given school profile page with media gallery on overview'
    include_context 'with Alameda High School'

    it { is_expected.to have_media_gallery }
    with_subject :media_gallery do
      # it { is_expected.to have_placeholder_image }
    end
  end

  describe 'zillow module' do
    include_context 'Given school profile page with zillow module'
    include_context 'with Alameda High School'
    it { is_expected.to have_zillow_header }
    it {is_expected.to have_zillow_content }
  end
  describe 'quick links module' do
    include_context 'Given school profile page with quick links'
    include_context 'with Alameda High School'
    it { is_expected.to have_quick_links }
  end

end


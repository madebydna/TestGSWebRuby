require 'spec_helper'
require 'features/localized_profiles/school_profile_features'

feature 'School profile overview page' do
  let!(:profile_page) { FactoryGirl.create(:page, name: 'Overview') }
  let(:school) do
    FactoryGirl.create(:alameda_high_school)
  end
  subject do
    visit school_path(school)
    page
  end
  after do
    clean_models School, Page
  end

  it_behaves_like 'school profile page', 'Overview'

  feature 'breadcrumbs' do
    context 'when on a washington, dc profile page' do
      let(:school) do
        s = FactoryGirl.build(:washington_dc_ps_head_start)
        s.on_db(:dc).save
        s
      end
      after do
        clean_models :dc, School
      end
      scenario 'State and city breadcrumbs says "/ District of Columbia / Washington, D.C."' do
        expect(subject).to have_content 'District of Columbia / Washington, D.C. / Schools / School Profile'
      end
    end

    context 'when on a san francisco, ca profile page' do
      let(:school) do
        FactoryGirl.create(:south_san_francisco_high_school)
      end
      scenario 'State and city breadcrumbs says "/ California / San Francisco"' do
        expect(subject).to have_content 'California / San Francisco / Schools / School Profile'
      end
    end
  end

  feature 'Apply now button' do
    after do
      clean_models :ca, School, SchoolMetadata
    end
    let(:apply_now_url) do
      SchoolMetadata.create(
        school_id: school.id,
        meta_key: 'apply_now_url',
        meta_value: 'http://www.schoolchoicede.org/ApplyInfo/AppoKN'
      )
    end

    context 'when on a school that has apply now url in school metadata' do
      before { apply_now_url }

      scenario 'An Apply Now button appears' do
        expect(subject).to have_button 'Apply now'
      end
    end

    context 'when on a school without an apply now url' do
      scenario 'An Apply Now button does not appear' do
        expect(subject).to_not have_button 'Apply now'
      end
    end
  end

  feature 'Apply now button' do
    after do
      clean_models :ca, School, SchoolMetadata
      clean_models CategoryPlacement
    end
    let(:facebook_url) do
      SchoolMetadata.create(
        school_id: school.id,
        meta_key: 'facebook_url',
        meta_value: 'blah'
      )
    end
    let(:facebook_section) do
      FactoryGirl.create(
        :category_placement,
        title: 'Facebook',
        page: profile_page,
        layout: 'section'
      )
    end
    let(:facebook_module) do
      FactoryGirl.create(
        :category_placement,
        page: profile_page,
        layout: 'facebook_like_box',
        parent: facebook_section
      )
    end

    context 'when on a school that has facebook url in school metadata' do
      before do
        facebook_url
        facebook_module
      end

      scenario 'A Facebook module appears' do
        expect(subject).to have_selector('h2', text: 'Facebook')
      end
    end

    context 'when on a school without an apply now url' do
      scenario 'A Facebook module does not appear' do
        expect(subject).to_not have_selector('h2', text: 'Facebook')
      end
    end
  end

end

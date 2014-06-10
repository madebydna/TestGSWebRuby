require 'spec_helper'
describe LocalizedProfileController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  it 'should have only four actions' do
    expect(controller.action_methods.size).to eq(4)
    expect(controller.action_methods - ['overview', 'reviews', 'quality', 'details']).to eq(Set.new)
  end

  shared_examples_for 'a configurable profile page' do |action|
    before do
      allow(controller).to receive(:find_school).and_return(school)
      allow(PageConfig).to receive(:new).and_return(page_config)
    end

    it 'should set the correct cannonical url' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:canonical_url]).to eq("http://localhost/california/alameda/#{school.id}-Alameda-High-School/")
    end

    it 'should set a PageConfig object' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:page_config]).to be_present
    end

    it 'should look up the correct school' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:school]).to eq(school)
    end

    it 'should set data needed for header' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:school_reviews_global]).to be_present
    end

    it 'should 404 with non-existent school' do
      allow(controller).to receive(:find_school).and_return(nil)
      get action, controller.view_context.school_params(school)
      expect(response.code).to eq('404')
    end

    it 'should convert a full state name to a state abbreviation' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:state]).to eq({ long: 'california', short: 'ca' })
    end

  end

  describe 'GET overview' do
    it_behaves_like 'a configurable profile page', 'overview'
  end

  describe 'GET quality' do
    it_behaves_like 'a configurable profile page', 'quality'
  end

  describe 'GET details' do
    it_behaves_like 'a configurable profile page', 'details'
  end

  describe 'GET reviews' do
    before do
      allow(controller).to receive(:find_school).and_return(school)
      allow(PageConfig).to receive(:new).and_return(page_config)
    end

    it 'should set the list of reviews' do
      reviews = [ instance_double(SchoolRating) ]
      expect(school).to receive(:reviews_filter).and_return(reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school_reviews]).to eq(reviews)
    end

    it 'should look up the correct school' do
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school]).to eq(school)
    end

    it 'should set data needed for header' do
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school_reviews_global]).to be_present
    end
  end

  describe 'Check SEO for school profile page' do

    describe '#seo_meta_tags_title' do
      it 'should set the title format correctly for Alameda High School' do
        #School.stub
        #get 'overview'
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'overview'
        school.level_code = 'h'
        school.name = 'Alameda High School'
        school.state = 'CA'
        school.city = 'Alameda'
        expect(controller.send(:seo_meta_tags_title)).to eq('Alameda High School - Alameda, California - CA - School overview')
      end

      it 'should set the title format correctly for the school PreK' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'overview'
        school.level_code = 'p'
        school.name = 'Greater St. Stephen Baptist Training'
        school.state = 'MI'
        school.city = 'Detroit'
        expect(controller.send(:seo_meta_tags_title)).to eq('Greater St. Stephen Baptist Training - Detroit, Michigan - MI - School overview')
      end

      it 'should set the title format correctly for the school in DC' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'overview'
        school.level_code = 'p'
        school.name = 'Amazing Life Games Pre-School'
        school.state = 'DC'
        school.city = 'Washington'
        expect(controller.send(:seo_meta_tags_title)).to eq('Amazing Life Games Pre-School - Washington, DC - School overview')
      end

    end

    describe '#seo_meta_tags_description' do

      it 'should set the description format for Alameda High School' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.level_code = 'h'
        school.name = 'Alameda High School'
        school.state = 'CA'
        school.city = 'Alameda'
        expect(controller.send(:seo_meta_tags_description)).to eq('Alameda High School located in Alameda, California - CA. Find Alameda High School test scores, student-teacher ratio, parent reviews and teacher stats.')
      end

      it 'should set the description format for Greater St. Stephen Baptist Training - PreK' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.name = 'Greater St. Stephen Baptist Training'
        school.level_code = 'p'
        school.state = 'MI'
        school.city = 'Detroit'
        expect(controller.send(:seo_meta_tags_description)).to eq('Greater St. Stephen Baptist Training in Detroit, Michigan (MI). Read parent reviews and get the scoop on the school environment, teachers, students, programs and services available from this preschool.')
      end

      it 'should set the description format for PreK in DC' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.level_code = 'p'
        school.name = 'Amazing Life Games Pre-School'
        school.state = 'DC'
        school.city = 'Washington'
        expect(controller.send(:seo_meta_tags_description)).to eq('Amazing Life Games Pre-School in Washington, Washington DC (DC). Read parent reviews and get the scoop on the school environment, teachers, students, programs and services available from this preschool.')
      end

    end

    describe '#seo_meta_tags_keywords' do

      it 'should set the keywords format for Alameda High School' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.level_code = 'h'
        school.name = 'Alameda High School'
        school.state = 'CA'
        school.city = 'Alameda'
        expect(controller.send(:seo_meta_tags_keywords)).to eq('Alameda High School, Alameda High School Alameda, Alameda High School Alameda California, Alameda High School Alameda CA, Alameda High School California, Alameda High School Overview')
      end

      it 'should set the keywords format for Greater St. Stephen Baptist Training' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.level_code = 'p'
        school.name = 'Greater St. Stephen Baptist Training'
        school.state = 'MI'
        school.city = 'Detroit'
        expect(controller.send(:seo_meta_tags_keywords)).to eq('Greater St. Stephen Baptist Training')
      end

      it 'should set the keywords format for a school in DC' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.level_code = 'p'
        school.name = 'Amazing Life Games Pre-School'
        school.state = 'DC'
        school.city = 'Washington'

        expect(controller.send(:seo_meta_tags_keywords)).to eq('Amazing Life Games Pre-School, Amazing Life Games Preschool')
      end

      it 'should include "pre-school" when school name ends with preschool' do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name).and_return 'Overview'
        school.level_code = 'p'
        school.name = 'ABC Preschool'
        school.state = 'DC'
        school.city = 'Washington'
        expect(controller.send(:seo_meta_tags_keywords))
          .to eq 'ABC Preschool, ABC Pre-School'
      end

    end

    describe '#redirect_to_canonical_url' do
      let(:school) {
        FactoryGirl.build(:school,
                          id: 1,
                          state: 'mi',
                          city: 'detroit',
                          name: 'a school'
                          )
      }

      before(:each) do
        controller.instance_variable_set(:@school, school)
        allow(controller).to receive(:action_name) { 'overview' }
      end

      it 'should redirect to the right path' do
        expect(controller).to receive(:redirect_to).
          with('/michigan/detroit/1-A-School/')
        controller.send :redirect_to_canonical_url
      end


      it 'should preserve url parameters when redirecting' do
        request.query_parameters[:preserve_me] = 'yay'
        expect(controller).to receive(:redirect_to).
          with('/michigan/detroit/1-A-School/?preserve_me=yay')
        controller.send :redirect_to_canonical_url
      end
    end

  end

  describe 'Ads are getting correct values in gon' do
    describe '#ad_setTargeting_through_gon' do
      let(:school) {
        FactoryGirl.build(:school,
                          id: 1,
                          state: 'CA',
                          city: 'San Francisco',
                          name: 'Alameda High School'
        )

      }

      before(:each) do
        controller.instance_variable_set(:@school, school.extend(SchoolProfileDataDecorator) )
        allow(school).to receive(:show_ads) { true }
        allow(school).to receive(:gs_rating) { nil }
        controller.send :ad_setTargeting_through_gon
      end

      it 'should have show ads true if we are going to have a gon object' do
        expect(school.show_ads).to eq(true)
      end

      it 'should school id defined in gon object' do
        expect(controller.gon.ad_set_targeting['school_id']).to eq( '1' )
      end

      it 'should City defined in gon object' do
        expect(controller.gon.ad_set_targeting['City']).to eq( 'SanFrancis' )
      end

      it 'should State defined in gon object' do
        expect(controller.gon.ad_set_targeting['State']).to eq( 'CA' )
      end
    end
  end
end

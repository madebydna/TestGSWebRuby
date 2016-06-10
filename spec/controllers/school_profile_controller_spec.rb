require 'spec_helper'
describe SchoolProfileController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  it 'should have no actions' do
    expect(controller.action_methods.size).to eq(0)
    expect(controller.action_methods - []).to eq(Set.new)
  end  

  # TODO: I think these specs are modifying the factory object in place. If so that is Very Bad and must be fixed.
  describe 'Check SEO for school profile page' do
    describe '#seo_meta_tags_title' do
      let (:subject) { controller.send(:seo_meta_tags_title) }
      describe 'for default versions' do
        let (:option_map) { Hash.new(:default) }

        before do
          allow(controller).to receive(:action_name).and_return 'overview'
          allow(controller).to receive(:title_state_options).and_return(option_map)
        end

        it 'should set the title format correctly for Alameda High School' do
          #School.stub
          #get 'overview'
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('Alameda High School - Alameda, California - CA - School overview')
        end

        it 'should set the title format correctly for a PreK' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'p'
          school.name = 'Greater St. Stephen Baptist Training'
          school.state = 'MI'
          school.city = 'Detroit'
          expect(subject).to eq('Greater St. Stephen Baptist Training - Detroit, Michigan - MI - School overview')
        end

        it 'should set the title format correctly for a school in DC' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'p'
          school.name = 'Amazing Life Games Pre-School'
          school.state = 'DC'
          school.city = 'Washington'
          expect(subject).to eq('Amazing Life Games Pre-School - Washington, DC - School overview')
        end
      end

      describe 'for option 1' do
        let (:option_map) { {'CA' => :option1} }

        before do
          allow(controller).to receive(:title_state_options).and_return(option_map)
        end

        it 'should have correctly formatted title' do
          controller.instance_variable_set(:@school, school)
          allow(controller).to receive(:action_name).and_return 'overview'
          school.name = 'The Athenian School'
          school.city = 'Danville'
          school.state = 'CA'
          expect(subject)
              .to eq 'The Athenian School 2016 Ratings | Danville, CA | GreatSchools'
        end

        it 'should not pull default title when page is not overview' do
          controller.instance_variable_set(:@school, school)
          allow(controller).to receive(:action_name).and_return 'quality'
          school.name = 'The Athenian School'
          school.city = 'Danville'
          school.state = 'CA'
          expect(subject)
              .to eq 'The Athenian School - Danville, California - CA - School quality'
        end
      end
    end

    describe '#title_state_options' do
      let (:subject) { controller.send(:title_state_options) }

      it 'should return a Hash' do
        expect(subject.class).to eq(Hash)
      end

      it 'should have a default value of :default' do
        expect(subject[:Atlantis]).to eq(:default)
      end
    end

    describe '#seo_meta_tags_description' do
      let (:subject) { controller.send(:seo_meta_tags_description) }

      before do
        allow(controller).to receive(:description_state_options).and_return(option_map)
      end

      describe 'for default option' do
        let (:option_map) { Hash.new(:default) }

        it 'should set the description format for Alameda High School' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('Alameda High School located in Alameda, California - CA. Find Alameda High School test scores, student-teacher ratio, parent reviews and teacher stats.')
        end

        it 'should set the description format for a PreK' do
          controller.instance_variable_set(:@school, school)
          school.name = 'Greater St. Stephen Baptist Training'
          school.level_code = 'p'
          school.state = 'MI'
          school.city = 'Detroit'
          expect(subject).to eq('Greater St. Stephen Baptist Training in Detroit, Michigan (MI). Read parent reviews and get the scoop on the school environment, teachers, students, programs and services available from this preschool.')
        end

        it 'should set the description format for PreK in DC' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'p'
          school.name = 'Amazing Life Games Pre-School'
          school.state = 'DC'
          school.city = 'Washington'
          expect(subject).to eq('Amazing Life Games Pre-School in Washington, Washington DC (DC). Read parent reviews and get the scoop on the school environment, teachers, students, programs and services available from this preschool.')
        end
      end

      describe 'for option 1' do
        let (:option_map) { {'CA' => :option1 } }

        it 'should have correctly formatted description' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('Newly updated test scores, student-teacher ratio, & diversity stats - Alameda High School reviews & ratings from parents and students.')
        end
      end

      describe 'for option 2' do
        let (:option_map) { {'CA' => :option2 } }

        it 'should have correctly formatted description' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('Read the latest reviews & ratings from parents and students about Alameda High School. Make the best decision for your child.')
        end
      end

      describe 'for option 3' do
        let (:option_map) { {'CA' => :option3 } }

        it 'should have correctly formatted description' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('Up-to-date test scores & in-depth statistics about Alameda High School. Read reviews & ratings from parents and students.')
        end
      end

      describe 'for option 4' do
        let (:option_map) { {'CA' => :option4 } }

        it 'should have correctly formatted description' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('Submit your rating for Alameda High School. Read reviews, newly-updated school & district test scores, and in-depth school report cards.')
        end
      end

      describe 'for option 5' do
        let (:option_map) { {'CA' => :option5 } }

        it 'should have correctly formatted description' do
          controller.instance_variable_set(:@school, school)
          school.level_code = 'h'
          school.name = 'Alameda High School'
          school.state = 'CA'
          school.city = 'Alameda'
          expect(subject).to eq('What do other parents think of Alameda High School? Read the largest review site for Alameda High School at GreatSchools.org.')
        end
      end
    end

    describe '#description_state_options' do
      let (:subject) { controller.send(:description_state_options) }

      it 'should return a Hash' do
        expect(subject.class).to eq(Hash)
      end

      it 'should have a default value of :default' do
        expect(subject[:Atlantis]).to eq(:default)
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
          with('/michigan/detroit/1-A-School/', {:status=>:moved_permanently})
        controller.send :redirect_to_canonical_url
      end


      it 'should preserve url parameters when redirecting' do
        request.query_parameters[:preserve_me] = 'yay'
        expect(controller).to receive(:redirect_to).
          with('/michigan/detroit/1-A-School/?preserve_me=yay', {:status=>:moved_permanently})
        controller.send :redirect_to_canonical_url
      end
    end

  end

  describe '#set_hreflang' do
    let(:school) {
      FactoryGirl.build(:school,
                        id: 1,
                        state: 'mi',
                        city: 'detroit'
      )
    }
    let(:env_global) { ENV_GLOBAL.to_hash.merge({'app_pk_host' => 'pk.greatschools.org'}) }

    before do
      controller.instance_variable_set(:@school, school)
      stub_const('ENV_GLOBAL', env_global)
    end

    subject {controller.send(:set_hreflang)}

    it {should be_a Hash}
    it {should have_key(:en)}
    it {should have_key(:es)}

    context 'for a preschool' do
      before do
        school.level_code = 'p'
        school.name = 'ABC Preschool'
      end

      it 'should use pk subdomain for english' do
        expect(subject[:en]).to eq 'http://pk.greatschools.org/michigan/detroit/preschools/ABC-Preschool/1/'
      end

      it 'should use pk subdomain for spanish' do
        expect(subject[:es]).to eq 'http://pk.greatschools.org/michigan/detroit/preschools/ABC-Preschool/1/?lang=es'
      end
    end

    context 'for an elementary school' do
      before do
        school.level_code='e'
        school.name='Test School'
      end

      it 'should not use pk subdomain for english' do
        expect(subject[:en]).to eq 'http://localhost/michigan/detroit/1-Test-School/'
      end

      it 'should not use pk subdomain for spanish' do
        expect(subject[:es]).to eq 'http://localhost/michigan/detroit/1-Test-School/?lang=es'
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

  it 'should respond to set_noindex_meta_tags' do
    expect(subject.respond_to?(:set_noindex_meta_tags, true)).to be_truthy
  end
  describe '#set_noindex_meta_tags' do
    subject { controller.send(:set_noindex_meta_tags) }
    it 'should call set_meta_tags with the correct hash' do
      expected_hash = {
        robots: 'noindex, nofollow, noarchive'
      }
      expect(controller).to receive(:set_meta_tags).with(expected_hash)
      subject
    end
  end

  describe '#set_state_school_id_gon_var' do
    it 'should set state and school_id to gon' do
      controller.instance_variable_set(:@school, school.extend(SchoolProfileDataDecorator) )
      controller.send(:set_state_school_id_gon_var)
      gon = controller.gon
      expect(gon.state).to eql(school.state)
      expect(gon.school_id).to eql(school.id)
    end

    it 'should have the callback as a before action' do
      all_callbacks = controller._process_action_callbacks
      callback = all_callbacks.select { |s| s.instance_variable_get(:@key) == :set_state_school_id_gon_var }
      expect(callback.present?).to be_truthy
    end
  end

  describe '#set_school_district_id' do
    it 'should set school district_id correctly' do
      this_school = FactoryGirl.create(:school, :with_district)
      allow(this_school).to receive(:gs_rating).and_return 10
      controller.instance_variable_set(:@school, this_school)
      page_view_metadata = controller.send(:page_view_metadata)
      expect(page_view_metadata['district_id']).to eql(this_school.district.id.to_s)
    end
    after do
      clean_dbs :ca
    end

    it 'should return empty string if school has no district_id' do
      this_school = FactoryGirl.create(:school)
      allow(this_school).to receive(:gs_rating).and_return 10
      controller.instance_variable_set(:@school, this_school)
      page_view_metadata = controller.send(:page_view_metadata)
      expect(page_view_metadata['district_id']).to eql("")
    end
    after do
      clean_dbs :ca
    end
  end

  it 'should respond to school_reviews' do
    expect(subject.respond_to?(:school_reviews, true)).to be_truthy
  end
  describe '#school_reviews' do
    subject { controller.send(:school_reviews) }
    let(:school_reviews) do
      collection = SchoolReviews.new
      collection.instance_variable_set(:@reviews, FactoryGirl.build_list(:five_star_review, 2))
      collection
    end
    let(:school) { double('school').as_null_object }

    context 'given a school object that has reviews with calculations' do
      before do
        allow(school).to receive(:reviews_with_calculations).and_return(school_reviews)
        controller.instance_variable_set(:@school, school)
      end

      it { is_expected.to be_a(SchoolProfileReviewsDecorator) }
      its('reviews.size') { is_expected.to eq(2) }
      it 'should memoize the result' do
        expect(SchoolProfileReviewsDecorator).to receive(:decorate).once
        2.times { subject }
      end

      it 'should not tell school_reviews to promote the specified review to top of list' do
        expect(school_reviews).to_not receive(:promote_review!)
        subject
      end

      context 'when a review_id param is present' do
        before do
          controller.params[:review_id] = '1'
        end
        it 'should tell school_reviews to promote the specified review to top of list' do
          expect(school_reviews).to receive(:promote_review!).with(controller.params[:review_id].to_i)
          subject
        end
      end
    end
  end
end

require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

describe SchoolProfileDecorator do
  it_behaves_like 'a school that has grade levels' do
    let(:school) { SchoolProfileDecorator.decorate(FactoryGirl.build(:school)) }
  end

  describe "#school_zip_location_search_url" do
    subject do
      SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school,lat: 30.111, lon: -120.22, zipcode: 90406, type: 'private'))
    end
    it "should return url" do
      search_url = '/search/search.page'
      search_url << '?distance=5'
      search_url << '&lat=30.111'
      search_url << '&locationSearchString=90406'
      search_url << '&locationType=street_address'
      search_url << '&lon=-120.22'
      search_url += '&normalizedAddress=90406'
      search_url << '&sort=distance_asc'
      search_url << '&sortBy=DISTANCE'
      search_url << '&state=CA'
      expect(subject.school_zip_location_search_url).to eq(search_url)
    end
  end

  describe '#school_level_and_address_location_search_sorted_by_rating_url' do
    before do 
      allow(subject).to receive(:google_formatted_street_address).and_return('googleformattedaddress')
      allow(subject).to receive(:full_address).and_return('fulladdress')
    end
    context 'with one level for a school' do
      subject do
        SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school,lat: 30.111, lon: -120.22, type: 'private', level_code: 'e'))
      end
      it 'should return url' do
        search_url = '/search/search.page'
        search_url << '?distance=3'
        search_url << '&gradeLevels%5B%5D=e'
        search_url << '&lat=30.111'
        search_url << '&locationSearchString=fulladdress'
        search_url << '&locationType=street_address'
        search_url << '&lon=-120.22'
        search_url += '&normalizedAddress=googleformattedaddress'
        search_url << '&sort=rating_desc'
        search_url << '&state=CA'
        expect(subject.school_level_and_address_location_search_sorted_by_rating_url).to eq(search_url)
      end
    end

    context 'with two levels for a school' do
      subject do
        SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school,lat: 30.111, lon: -120.22, type: 'private', level_code: 'e,m'))
      end
      it 'should return url' do
        search_url = '/search/search.page'
        search_url << '?distance=3'
        search_url << '&gradeLevels%5B%5D=e&gradeLevels%5B%5D=m'
        search_url << '&lat=30.111'
        search_url << '&locationSearchString=fulladdress'
        search_url << '&locationType=street_address'
        search_url << '&lon=-120.22'
        search_url += '&normalizedAddress=googleformattedaddress'
        search_url << '&sort=rating_desc'
        search_url << '&state=CA'
        expect(subject.school_level_and_address_location_search_sorted_by_rating_url).to eq(search_url)
      end
    end
  end

  describe "#type_url" do
    before do
      @district = FactoryGirl.create(:district, name: 'Alameda City Unified')
    end
    after do
      clean_dbs :ca
    end
    context "with a public school" do
      subject do
        SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school, lat: 30.111, lon: -120.22, zipcode: 90406, district_id: @district.id))
      end
      it "should return district browse for public schools" do
        type_url = 'http://localhost/california/alameda/alameda-city-unified/schools/'
        expect(subject.school_type_url).to eq(type_url)
      end
    end
    context "with private schools" do
      subject do
        SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school, lat: 30.111, lon: -120.22, zipcode: 90406, district_id: 1, type: 'private'))
      end
      it "should return city browse for private schools" do
        type_url = 'http://localhost/california/alameda/schools/?st=private'
        expect(subject.school_type_url).to eq(type_url)
      end
    end
    context "with charter schools" do
      subject do
        SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school, lat: 30.111, lon: -120.22, zipcode: 90406, district_id: 1, type: 'charter'))
      end
      it "should return city browse for charter schools" do
        type_url = 'http://localhost/california/alameda/schools/?st=charter'
        expect(subject.school_type_url).to eq(type_url)
      end
    end

  end




end

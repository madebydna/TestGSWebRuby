require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

describe SchoolProfileDecorator do
  it_behaves_like 'a school that has grade levels' do
    let(:school) { SchoolProfileDecorator.decorate(FactoryGirl.build(:school)) }
  end

  describe "#school_zip_location_search_url" do
    subject do
      SchoolProfileDecorator.decorate(FactoryGirl.build(:alameda_high_school,lat: 30.111, lon: -120.22, zipcode: 90406))
    end
    it "should return url" do
     search_url = '/search/search.page?lat=30.111&lon=-120.22&state=CA&locationType=street_address&'
     search_url += 'normalizedAddress=90406''&sortBy=DISTANCE&locationSearchString=90406&distance=5&sort=distance_asc'
      expect(subject.school_zip_location_search_url).to eq(search_url)
    end
  end
end

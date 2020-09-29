require "spec_helper"

describe 'Newsletter:DistrictGradeByGrade' do

  subject { Newsletter::DistrictGradeByGrade }
  before do
    @district = create(:stockton_unified_school_district)
  end
  after { do_clean_dbs :gs_schooldb }

  describe '#district' do
    it 'returns nil if the route is not recognized' do
      expect(subject.new('fake-district-url').district).to be_nil
    end

    it 'returns a district record if it is recognized' do
      expect(subject.new('susd').district).to eq(@district)
    end
  end

  describe '#logo' do
    it 'returns a route for the logo if district route is recognized' do
      expect(subject.new('susd').logo).to eq('district_logos/susd-logo.png')
    end

    it 'returns nil if the route is not recognized' do
      expect(subject.new('fake-district-url').logo).to be_nil
    end
  end
end
require 'spec_helper'

describe 'SchoolProfiles::DataPoint::Formatters' do

  describe '.round_unless_less_than_1' do
    it 'handles string that contains decimal value that is less than 1' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1('0.51')).to eq('<1')
    end
    it 'handles string that contains decimal value that is greater than 1' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1('1.51')).to eq(2)
    end
    it 'handles string "1"' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1('1')).to eq(1)
    end
    it 'handles string "0"' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1("0")).to eq('<1')
    end
    it 'handles 0' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1(0)).to eq('<1')
    end
    it 'handles decimal value less than 1' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1(0.51)).to eq('<1')
    end
    it 'handles decimal value greater than 1' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1(1.51)).to eq(2)
    end
    it 'handles strings that contains numbers' do
      expect(SchoolProfiles::DataPoint::Formatters.round_unless_less_than_1('<95%')).to eq('<95%')
    end
  end

end

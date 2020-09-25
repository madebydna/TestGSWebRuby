require "spec_helper"

describe CommunityProfiles::DistanceLearning do
  subject { CommunityProfiles::DistanceLearning.new(double('district_cache_data_reader')) }

  describe '#show_more_link?' do
    it 'return true if more than one datatype' do
      datatypes = ['LEARNING MODEL', 'REMOTE LEARNING']
      expect(subject.show_more_link?(datatypes)).to eq(true)
    end

    it 'return false if less than one datatype' do
      datatypes = ['LEARNING MODEL']
      expect(subject.show_more_link?(datatypes)).to eq(false)
      expect(subject.show_more_link?([])).to eq(false)
    end
  end
end
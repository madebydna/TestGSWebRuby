require 'spec_helper'

describe CommunityScorecardData do
  describe '#school_data' do
    subject { CommunityScorecardData.new }
    it 'should use SchoolDataHash to get school info' do
      allow(nil).to receive(:data_hash)
      allow(subject).to receive(:get_cachified_schools).and_return([1,2,3,4])
      expect(SchoolDataHash).to receive(:new).exactly(4).times
      subject.school_data
    end
  end
end

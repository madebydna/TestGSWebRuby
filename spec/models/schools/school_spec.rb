require 'spec_helper'

describe School do

  describe '#held?' do
    let(:school) { FactoryGirl.build(:school) }
    it 'should return true because the school is held' do
      allow(HeldSchool).to receive(:exists?).and_return(true)
      expect(school.held?).to be_truthy
    end

    it 'should return false because the school is not held' do
      allow(HeldSchool).to receive(:exists?).and_return(false)
      expect(school.held?).to be_falsey
    end
  end

  describe '#school_metadata' do
    let(:school) { FactoryGirl.build(:school) }
    it 'should return a Hashie::Mash object' do
      schoolMetadata = school.school_metadata
      expect(schoolMetadata).to be_a Hashie::Mash
    end
  end

  describe '#great_schools_rating' do
    subject(:school) { FactoryGirl.build(:school) }
    before do
      school_metadata = Hashie::Mash.new(:overallRating => "10")
      allow(school).to receive(:school_metadata).and_return(school_metadata)
    end

    context 'when a school has a great schools rating' do
      it 'should return a great schools rating' do
        expect(school.great_schools_rating).to eq '10'
      end
    end
    context 'when a school does not have a great schools rating' do
      before { allow(school).to receive(:school_metadata).and_return(Hashie::Mash.new) }
      it 'should return nil' do
        expect(school.great_schools_rating).to be_nil
      end
    end
  end
end

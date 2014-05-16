require 'spec_helper'

describe School do

  describe '#process_level' do

    it 'should return nil if levels array is empty'  do
      school = FactoryGirl.build(:school, level: '')
      expect(school.process_level).to be_nil
    end

    it 'should transform the input level array correctly into a formatted string connected levels' do
      school = FactoryGirl.build(:school, level: 'PK,KG')
      expect(school.process_level).to eq 'PK-K'
    end

    it 'should transform the input level array correctly into a formatted string connected levels extended version' do
      school = FactoryGirl.build(:school, level: 'PK,KG,1,2,3,4,5')
      expect(school.process_level).to eq 'PK-5'
    end

    it 'should transform the input level array correctly into a formatted string connected levels 3 with Ungraded appended' do
      school = FactoryGirl.build(:school, level: 'PK,KG,1,2,3,4,5,UG')
      expect(school.process_level).to eq 'PK-5 & Ungraded'
    end

    it 'should transform the input level array correctly into a formatted string with connected levels and commas between series or instances' do
      school = FactoryGirl.build(:school, level: 'PK,KG,1,3,4,5')
      expect(school.process_level).to eq 'PK-1, 3-5'
    end

    it 'should transform the input level array with no series to levels separated by comma/s' do
      school = FactoryGirl.build(:school, level: '7,11')
      expect(school.process_level).to eq '7, 11'
    end

    it 'should transform KG into K'   do
      school = FactoryGirl.build(:school, level: 'KG')
      expect(school.process_level).to eq 'K'
    end

    it 'should transform UG into Ungraded' do
      school = FactoryGirl.build(:school, level: 'UG')
      expect(school.process_level).to eq 'Ungraded'
    end

    it 'should transform an individual grade that is not a special case' do
      school = FactoryGirl.build(:school, level: '10')
      expect(school.process_level).to eq '10'
    end

    it 'should transform the input array "level" to a mix of series and gaps' do
      school = FactoryGirl.build(:school, level: 'PK,1,2,3,6,9,10,11,12')
      expect(school.process_level).to eq 'PK, 1-3, 6, 9-12'
    end

    it 'should transform the input array "level" to a one continuous series' do
      school = FactoryGirl.build(:school, level: 'PK,KG,1,2,3,4,5,6,7,8,9,10,11,12')
      expect(school.process_level).to eq 'PK-12'
    end
  end

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

  describe '#description' do
    subject(:school) { FactoryGirl.build(:school) }
    before do
      allow(school).to receive(:great_schools_rating).and_return('10')
      allow(school).to receive(:level).and_return('9,10,11,12')
    end

    it 'should return a description string of the school' do
      expect(school.description).to be_a_kind_of String
    end
    it 'should include the school name in the description' do
      expect(school.description).to include 'Alameda High School'
    end
    it 'should include the school type in the description' do
      expect(school.description).to include 'public'
    end
    it 'should include the school grade levels in the description' do
      expect(school.description).to include '9-12'
    end

    context 'when a school does not have a name' do
      before { allow(school).to receive(:name).and_return('') }
      it 'should return nil' do
        expect(school.description).to be_nil
      end
    end

    context 'when a school has only ungraded schools' do
      before { allow(school).to receive(:levels_description).and_return(nil) }
      subject(:description) { school.description }
      it { should_not include 'that serves grade'}
    end

    context 'when a school has only one grade level' do
      before { allow(school).to receive(:levels_description).and_return('grade 1') }
      subject(:description) { school.description }
      it { should include 'that serves grade 1'}
      it { should_not include 'that serves grades 1'}
    end

    context 'when a school has multiple grade levels' do
      before { allow(school).to receive(:levels_description).and_return('grades 1-6') }
      subject(:description) { school.description }
      it { should include 'that serves grades 1-6'}
      it { should_not include 'that serves grade 1-6'}
    end

    context 'when a school has non-consecutive grade levels' do
      before { allow(school).to receive(:levels_description).and_return('grades K-5, 9-12') }
      subject(:description) { school.description }
      it { should include 'that serves grades K-5, 9-12'}
    end

    context 'when a school has a great schools rating' do
      it 'should include the great schools rating in the school description' do
        expect(school.description).to include 'rating of 10 out of 10'
      end
    end
    context 'when a school does not have a great schools rating' do
      before { allow(school).to receive(:great_schools_rating).and_return(nil) }
      it 'should not contain the great schools rating text' do
        expect(school.description).to_not include 'It has received a GreatSchools rating of'
      end
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

  describe '#levels_description' do
    subject(:school) { FactoryGirl.build(:school) }
    context 'when a school does not have grade levels' do
      before { allow(school).to receive(:process_level).and_return(nil) }
      subject(:levels_description) { school.levels_description }
      it { should be_nil }
    end
    context 'when a school has only ungraded schools' do
      before { allow(school).to receive(:process_level).and_return('Ungraded') }
      subject(:levels_description) { school.levels_description }
      it { should be_nil }
    end
    context 'when a school has graded and ungraded schools' do
      before { allow(school).to receive(:process_level).and_return('K-12 & Ungraded') }
      subject(:levels_description) { school.levels_description }
      it { should be_nil }
    end
    context 'when a school has a single grade level' do
      before { allow(school).to receive(:process_level).and_return('K') }
      subject(:levels_description) { school.levels_description }
      it { should match /grade K/ }
    end
    context 'when a school has a multiple grade levels' do
      before { allow(school).to receive(:process_level).and_return('K-12') }
      subject(:levels_description) { school.levels_description }
      it { should match /grades K-12/ }
    end
    context 'when a school has non-consecutive of grade levels' do
      before { allow(school).to receive(:process_level).and_return('K-5, 8-10') }
      subject(:levels_description) { school.levels_description }
      it { should match /grades K-5, 8-10/ }
    end
  end
end

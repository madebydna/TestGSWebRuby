require 'spec_helper'
describe School do

  after do
    clean_models School,SchoolMetadata
  end

  after(:each) { clean_dbs :ca }

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

  describe '#preload_school_metadata' do
    let(:school_with_gs_ratings) { FactoryGirl.create(:school,:with_gs_rating,gs_rating: 3 ) }
    let(:school_with_no_ratings) { FactoryGirl.create(:the_friendship_preschool,id: 3) }
    let(:all_schools) {Array(school_with_gs_ratings) + Array(school_with_no_ratings)}

    it 'should set rating if a school has rating else an empty hash.' do
      School.preload_school_metadata!(all_schools)
      expect(all_schools.first.instance_variable_get(:@school_metadata)).to eq(Hashie::Mash.new(:overallRating => "3"))
      expect(all_schools.last.instance_variable_get(:@school_metadata)).to eq(Hashie::Mash.new())
    end

    context 'when school_metadata is preloaded' do
      it 'should not query the database for rating' do
        School.preload_school_metadata!(all_schools)
        expect(SchoolMetadata).to_not receive(:by_school_id)
        school_with_gs_ratings.great_schools_rating
        school_with_no_ratings.great_schools_rating
      end

      it 'should query the database for the ratings' do
        expect(SchoolMetadata).to receive(:by_school_id).exactly(2).times.and_call_original
        expect(school_with_gs_ratings.great_schools_rating).to eq('3')
        expect(school_with_no_ratings.great_schools_rating).to be_nil
      end
    end

  end
end

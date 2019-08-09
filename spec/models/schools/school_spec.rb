require 'spec_helper'
describe School do

  after do
    clean_models :ca, School,SchoolMetadata
  end

  after(:each) { clean_dbs :ca }

  describe 'scopes' do
    levels = %w(preschool elementary middle high)
    types = %w(private public charter)

    types.each do |type|
      describe ".#{type}_schools" do
        before do
          @school = FactoryGirl.create_on_shard(:ca, :school, level_code: 'p,e', type: School::LEVEL_CODES[type.to_sym])
        end

        it 'returns the school' do
          expect(School.on_db(:ca).send("#{type}_schools".to_sym)).to include(@school)
        end
      end
    end

    levels.each_with_index do |level, i|
      describe ".#{level}_schools" do
        context "with single level" do
          before do
            @school = FactoryGirl.create_on_shard(:ca, :school, level_code: School::LEVEL_CODES[level.to_sym], type: 'public')
          end
          it 'returns the school' do
            expect(School.on_db(:ca).send("#{level}_schools".to_sym)).to include(@school)
          end
        end
        context "with multiple levels" do
          before do
            l1 = School::LEVEL_CODES[level.to_sym]
            other_code = levels[i % levels.length - 1].to_sym
            l2 = School::LEVEL_CODES[other_code]
            @school = FactoryGirl.create_on_shard(:ca, :school, level_code: [l1,l2].join(',') , type: 'public')
          end
          it 'returns the school' do
            expect(School.on_db(:ca).send("#{level}_schools".to_sym)).to include(@school)
          end
        end
      end
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
    let(:school_with_no_ratings) { FactoryGirl.create(:the_friendship_preschool) }
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

  describe '#cache_results' do
    let(:school) { FactoryGirl.create(:school) }

    it 'should query the school cache only once.' do
      expect(school).to memoize(:cache_results)
    end

  end

  it { is_expected.to respond_to(:demo_school?) }
  describe '#demo_school?' do
    context 'when notes containts string "GREATSCHOOLS_DEMO_SCHOOL_PROFILE"' do
      before { subject.notes = 'foo GREATSCHOOLS_DEMO_SCHOOL_PROFILE bar' }
      it { is_expected.to be_demo_school }
    end
    context 'when notes is nil' do
      before { subject.notes = nil }
      it { is_expected.to_not be_demo_school }
    end
    context 'when notes is some miscellaneous text' do
      before { subject.notes = 'sljf lsdkjf lsdj fljskf' }
      it { is_expected.to_not be_demo_school }
    end
  end

  describe '#nearby_schools_for_list' do
    let(:school) { FactoryGirl.build(:school) }
    CacheResultsStruct = Struct.new(:nearby_schools)
    context 'when the cache is present and a hash' do
      let(:cache_results) do
        CacheResultsStruct.new(legit_list: [:school1, :school2])
      end
      before do
        allow(school).to receive(:cache_results).and_return(cache_results)
      end
      context 'when the list provided is a key of the hash' do
        let(:list) { :legit_list }
        it 'should return the correct value' do
          expect(school.nearby_schools_for_list(list)).to eq([:school1, :school2])
        end
      end
      context 'when the list provided is not a key of the hash' do
        let(:list) { :not_legit_list }
        it 'should return an empty array' do
          expect(school.nearby_schools_for_list(list)).to eq([])
        end
      end
    end
    context 'when the cache is present and not a hash' do
      let(:cache_results) do
        CacheResultsStruct.new([:school1, :school2])
      end
      before do
        allow(school).to receive(:cache_results).and_return(cache_results)
      end
      let(:list) { :not_legit_list }
      it 'should return an empty array' do
        expect(school.nearby_schools_for_list(list)).to eq([])
      end
    end
    context 'when the cache is not present' do
      before do
        allow(school).to receive(:cache_results).and_return(nil)
      end
      let(:list) { :not_legit_list }
      it 'should return an empty array' do
        expect(school.nearby_schools_for_list(list)).to eq([])
      end
    end
  end

end

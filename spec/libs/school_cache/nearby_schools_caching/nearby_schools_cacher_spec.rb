require 'spec_helper'

describe NearbySchoolsCaching::NearbySchoolsCacher do
  let(:decorator) { NearbySchoolsCaching::QueryResultDecorator }
  methodologies = [
    NearbySchoolsCaching::Methodologies::ClosestSchools,
    NearbySchoolsCaching::Methodologies::TopNearbySchools,
    NearbySchoolsCaching::Methodologies::ClosestTopSchools
  ]

  describe '#build_hash_for_cache' do
    before do
      methodologies.each do |methodology|
        allow(methodology).to receive(:results).and_return([])
      end
    end

    context 'for a school in collection 14' do
      let(:school) { FactoryGirl.build(:alameda_high_school) }
      let(:nearby_schools_cacher) do
        NearbySchoolsCaching::NearbySchoolsCacher.new(school)
      end
      let(:expected_result) do
        {
          closest_schools: [],
          closest_top_then_top_nearby_schools: [],
        }
      end
      before do
        allow(school).to receive(:collection_ids).and_return([14])
      end

      it 'should build the correct lists' do
        expect(nearby_schools_cacher.build_hash_for_cache).to eq(expected_result)
      end
    end

    context 'for a state not configured for more lists' do
      let(:school) { FactoryGirl.build(:alameda_high_school, state: 'NH') }
      let(:nearby_schools_cacher) do
        NearbySchoolsCaching::NearbySchoolsCacher.new(school)
      end
      let(:expected_result) do
        {
          closest_schools: [],
        }
      end

      it 'should build the correct lists' do
        expect(nearby_schools_cacher.build_hash_for_cache).to eq(expected_result)
      end
    end
  end

  describe 'methodologies' do
    methodologies.each do |methodology|
      context "#{methodology}" do
        it 'should implement #schools' do
          begin
            methodology.schools(nil, {})
          rescue Exception => e
            expect(e.class).to_not eq(NotImplementedError)
          end
        end
      end
    end
  end
end

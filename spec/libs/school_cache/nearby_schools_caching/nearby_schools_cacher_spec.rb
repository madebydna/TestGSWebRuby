require 'spec_helper'

describe NearbySchoolsCaching::NearbySchoolsCacher do
  let(:decorator) { NearbySchoolsCaching::QueryResultDecorator }
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:nearby_schools_cacher) do
    NearbySchoolsCaching::NearbySchoolsCacher.new(school)
  end
  methodologies = [
    NearbySchoolsCaching::Methodologies::ClosestSchools,
    NearbySchoolsCaching::Methodologies::TopNearbySchools,
    NearbySchoolsCaching::Methodologies::ClosestTopSchools
  ]

  describe '#build_hash_for_cache' do
    let(:expected_result) do
      {
        NearbySchoolsCaching::Methodologies::ClosestSchools::NAME => [],
      }
    end
    before do
      methodologies.each do |methodology|
        allow(methodology).to receive(:results).and_return([])
      end
    end
    it 'should build the correct structure' do
      expect(nearby_schools_cacher.build_hash_for_cache).to eq(expected_result)
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

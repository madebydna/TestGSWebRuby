require 'spec_helper'

describe CommunityScorecardData do
  let(:scorecard_fields) {
    [
      { data_type: :school_info, partial: :school_info },
      { data_type: :a_through_g, partial: :percent_value, year: 2014 },
      { data_type: :graduation_rate, partial: :percent_value, year: 2013 },
    ]
  }
  let(:collection_struct) { Struct.new(:scorecard_fields) }
  let(:data_sets) { ['a_through_g', 'graduation_rate'] }

  subject { CommunityScorecardData.new }

  describe '#school_data' do
    it 'should use SchoolDataHash to get school info' do
      class FakeKlass; end
      allow(SchoolDataHash).to receive(:new).and_return(FakeKlass)
      allow(FakeKlass).to receive(:data_hash)
      structed_collection = collection_struct.new(scorecard_fields)
      allow(Collection).to receive(:find).and_return(structed_collection)
      allow(subject).to receive(:get_cachified_schools).and_return([1,2,3,4])
      expect(SchoolDataHash).to receive(:new).exactly(4).times
      subject.school_data
    end
  end

  describe '#data_sets_with_years' do
    it 'should create the correct structure' do
      [
        [scorecard_fields, { a_through_g: 2014, graduation_rate: 2013 }.with_indifferent_access],
        [scorecard_fields.reverse, { graduation_rate: 2013, a_through_g: 2014 }.with_indifferent_access]
      ].each do |scorecard_field_set, correct_structure|
        structed_collection = collection_struct.new(scorecard_field_set)
        allow(Collection).to receive(:find).and_return(structed_collection)
        expect(subject.data_sets_with_years(data_sets)).to eq(correct_structure)
      end
    end
  end
end

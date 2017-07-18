require 'spec_helper'

describe RatingsCacher do

  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { RatingsCacher.new(school) }

  describe '#cache' do
    subject { cacher.cache }

    context 'with current ratings' do
      before do
        allow(cacher).to receive(:current_ratings).and_return(
          [
            OpenStruct.new(
              id: 1,
              test_data_type: OpenStruct.new(display_name: 'foo'),
              data_type_id: 10
            ),
            OpenStruct.new(
              id: 2,
              test_data_type: OpenStruct.new(display_name: 'foo'),
              data_type_id: 20 
            )
          ]
        )
      end
      it 'should fetch historic ratings only for data types with current ratings' do

        expect(TestDataSet).to receive(:historic_ratings_for_school).with(
          eq(school),
          eq([10,20]),
          eq([1,2])
        ).and_return([])

        subject
      end
    end

    context 'with no current ratings' do
      before do
        allow(cacher).to receive(:current_ratings).and_return([])
      end
      it 'should not try to fetch historical ratings' do
        expect(TestDataSet).to_not receive(:historic_ratings_for_school)
        subject
      end
    end
  end

  describe '#current_rating_hashes' do
    subject { cacher.current_rating_hashes }
    before do
      allow(cacher).to receive(:current_ratings).and_return(
        [
          OpenStruct.new(
            test_data_type: OpenStruct.new(display_name: 'foo'),
            data_type_id: 1
          ),
          OpenStruct.new(
            test_data_type: OpenStruct.new(display_name: 'foo'),
            data_type_id: 164
          ),
          OpenStruct.new(
            test_data_type: OpenStruct.new(display_name: 'foo'),
            data_type_id: 165
          ),
          OpenStruct.new(
            test_data_type: OpenStruct.new(display_name: 'foo'),
            data_type_id: 2
          )
        ]
      )
    end

    it 'adds description and methodology to test score rating' do
      expect(subject[1]).to have_key(:description)
      expect(subject[1]).to have_key(:methodology)
    end

    it 'adds description and methodology to growth rating' do
      expect(subject[2]).to have_key(:description)
      expect(subject[2]).to have_key(:methodology)
    end

    it 'should not add methodology to other data sets' do
      expect(subject[0]).to_not have_key(:description)
      expect(subject[0]).to_not have_key(:methodology)
      expect(subject[3]).to_not have_key(:description)
      expect(subject[3]).to_not have_key(:methodology)
    end
  end

  describe '#data_set_to_hash' do
    let(:data_set) do
      OpenStruct.new(
        data_type_id: 10,
        year: 2100,
        school_value_text: '<2',
        school_value_float: 1.8,
        level_code: 'e,m,h',
        test_data_type: OpenStruct.new(display_name: 'foo'),
        breakdown_id: 1
      )
    end
    subject { cacher.data_set_to_hash(data_set) }
    before do
      allow(cacher.class).to receive(:test_data_breakdowns).and_return(
        1 => { 'name' => 'foo' }
      )
    end
    its('data_type_id') { is_expected.to eq(10) }
    its('year') { is_expected.to eq(2100) }
    its('school_value_text') { is_expected.to eq('<2') }
    its('school_value_float') { is_expected.to eq(1.8) }
    its('level_code') { is_expected.to eq('e,m,h') }
    its('breakdown') { is_expected.to eq('foo') }

    context 'when breakdown is not found' do
      before do
        allow(cacher.class).to receive(:test_data_breakdowns).and_return({})
      end
      its('breakdown') { is_expected.to be_nil }

      its('data_type_id') { is_expected.to eq(10) }
      its('year') { is_expected.to eq(2100) }
      its('school_value_text') { is_expected.to eq('<2') }
      its('school_value_float') { is_expected.to eq(1.8) }
      its('level_code') { is_expected.to eq('e,m,h') }
    end
  end

end

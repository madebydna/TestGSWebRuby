require 'spec_helper'

describe RatingsCaching::RatingsCacher do

  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { RatingsCaching::RatingsCacher.new(school) }


  describe '#cache' do
    after(:each) do
      clean_models :ca, School, TestDataSet, TestDataSchoolValue
      clean_models TestDataType, SchoolCache, TestDataBreakdown, TestDataSubject
    end

    subject { cacher.cache }

    context 'when a school has actual ratings data' do
      let!(:test_data_type) do
        FactoryGirl.create(
          :test_data_type,
          classification: 'gs_rating'
        )
      end
      let!(:test_data_set) do
        FactoryGirl.create(
          :test_data_set,
          :with_school_values,
          data_type_id: test_data_type.id,
          breakdown_id: 1,
          subject_id: 1,
          display_target: 'ratings',
          school_id: school.id,
          value_float: 2,
          value_text: '3'
        )
      end

      it 'should insert ratings for the school' do
        subject

        cache_row = SchoolCache.where("school_id = ? and state = ?", school.id,school.state)

        expect(cache_row).to_not be_empty
        expect(cache_row.size).to eq(1)
        ratings = JSON.parse(cache_row[0].value)
        expect(ratings.size).to eq(1)
        expect(ratings[0]['data_type_id']).to eq(test_data_type.id)
        expect(ratings[0]['school_value_float']).to eq(2)
        expect(ratings[0]['school_value_text']).to eq('3')
      end
    end

    context 'when a school does not have ratings data' do
      it 'should not insert ratings for the school' do
        subject
        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')
        expect(cache_row).to be_empty
      end
    end

    context 'when a school does not have school values' do
      let!(:test_data_set) { FactoryGirl.create(:test_data_set, data_type_id: 1, display_target: 'ratings')}
      let!(:test_data_set) { FactoryGirl.create(:test_data_set, data_type_id: 2, display_target: 'ratings')}

      it 'should not insert ratings for the school' do
        subject
        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')
        expect(cache_row).to be_empty
      end
    end

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
        1 => OpenStruct.new('name' => 'foo')
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

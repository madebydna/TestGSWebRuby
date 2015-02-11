require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe CensusLoading::Loader do

  it_behaves_like 'a loader', CensusLoading::Loader

  describe '#insert_into!' do

    let(:data_type) { nil }
    let(:loader) { CensusLoading::Loader.new(nil, nil, 'fake source') }
    CensusUpdateStruct = Struct.new(:shard, :data_set_attributes, :entity_id_type, :entity_id, :value_type, :value, :value_class)
    let(:data_set_attributes) { { data_type_id: 1 } }
    let(:census_update) { CensusUpdateStruct.new(:ca, data_set_attributes, :school_id, 1, :value_float, 23, CensusDataSchoolValue) }

    after do
      clean_models :ca, CensusDataSet
      clean_models :ca, CensusDataSchoolValue
    end

    context 'data set' do
      it 'should be for the correct attributes' do
        @data_set = FactoryGirl.create(:census_data_set)
        allow(CensusDataSet).to receive(:find_or_create_and_activate).and_return(@data_set)
        expect(CensusDataSet).to receive(:find_or_create_and_activate).with(census_update.shard, census_update.data_set_attributes)
        loader.insert_into!(census_update)
      end
    end

    context 'the created value row' do
      before do
        @data_set = FactoryGirl.create(:census_data_set)
        allow(CensusDataSet).to receive(:find_or_create_and_activate).and_return(@data_set)
        loader.insert_into!(census_update)
        @value_row = CensusDataSchoolValue.on_db(census_update.shard).last
      end

      it 'should be active' do
        expect(@value_row.active).to eq(1)
      end

      it 'should have the correct data_set_id' do
        expect(@value_row.data_set_id).to eq(@data_set.id)
      end

      it 'should have the correct entity_id' do
        expect(@value_row.send(census_update.entity_id_type)).to eq(census_update.entity_id)
      end

      it 'should have the correct value' do
        expect(@value_row.send(census_update.value_type)).to eq(census_update.value)
      end

      it 'should have the correct modifiedBy' do
        expect(@value_row.modifiedBy).to eq('Queue daemon. Source: fake source')
      end
    end
  end

end
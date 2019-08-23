require 'spec_helper'

describe CensusLoading::Base do

  let(:valid_update_array) {
    [
        {
            entity_state:'DC',
            value: '2',
            entity_id: '349',
            entity_type: 'school',
            member_id: '5747142'
        }
    ]
  }
  let(:source) { 'osp' }
  let(:weird_case_data_type) { 'A dEsCrIPtion' } # The factory's description is 'a description'
  let(:census_data_type) { FactoryBot.build(:census_data_type) }
  let(:census_data_type_in_base_class_format) { [census_data_type.description, census_data_type] }

  context 'data types' do
    before do
      allow_any_instance_of(CensusLoading::Loader).to receive(:census_data_types).and_return([census_data_type_in_base_class_format])
    end
    it 'should find the correct data type even if the case is wrong' do
      loader = CensusLoading::Loader.new(weird_case_data_type, valid_update_array, source)
      expect(loader.census_data_type_from_name(weird_case_data_type)).to be_a(CensusDataType)
    end

    context 'a non-legit data type' do
      it 'should return nil' do
        loader = CensusLoading::Loader.new('not a data type', valid_update_array, source)
        expect(loader.census_data_type_from_name('not a data type')).to be_nil
      end
    end
  end

end

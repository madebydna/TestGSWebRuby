describe CensusDataSetJsonView do

  describe '#to_hash' do
    let(:hash) { CensusDataSetJsonView.new(census_data_set).to_hash }

    let(:census_data_set) {
      FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(
          :census_data_school_value, 1
        ),
        census_data_state_values: FactoryGirl.build_list(
          :census_data_state_value, 1
        )
      )
    }

    it 'should return a hash if data set has only a school value' do
      census_data_set.census_data_state_values = []
      census_data_set.census_data_district_values = []
      expect(hash).to be_present
    end

    it 'should return a hash if data set has only a state value' do
      census_data_set.census_data_school_values = []
      census_data_set.census_data_district_values = []
      expect(hash).to be_present
    end

    it 'should return nil if data set has no school values or state values' do
      census_data_set.census_data_school_values = []
      census_data_set.census_data_state_values = []
      expect(hash).to be_nil
    end

    context 'when data set has year 0' do
      let(:census_data_set) {
        FactoryGirl.build(:manual_override_data_set,
          census_data_school_values: FactoryGirl.build_list(
            :census_data_school_value,
            1,
            modified: '2010-11-01'
          )
        )
      }

      it 'should contain the year from school_modified field' do
        expect(hash[:year]).to eq 2010
      end
    end
  end
end
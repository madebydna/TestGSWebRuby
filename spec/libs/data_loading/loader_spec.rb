require 'spec_helper'

describe Loader do

  describe '#determine_loading_class' do

    context 'with a census data type' do

      before { allow(Loader).to receive(:census_data_type?).and_return(true) }

      it 'should return CensusLoading::Loader' do
        expect(Loader.determine_loading_class('data type name')).to eq(CensusLoading::Loader)
      end
    end

    context 'with a random data type' do

      it 'should return EspResponseLoading::Loader' do
        expect(Loader.determine_loading_class('random data type name')).to eq(EspResponseLoading::Loader)
      end
    end
  end
end
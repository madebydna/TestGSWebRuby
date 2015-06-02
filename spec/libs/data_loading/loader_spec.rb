require 'spec_helper'

describe Loader do

  describe '#determine_loading_class' do

    context 'with a census data type' do

      before { allow(Loader).to receive(:census_data_type?).and_return(true) }

      it 'should return CensusLoading::Loader' do
        expect(Loader.determine_loading_class('non osp','data type name')).to eq(CensusLoading::Loader)
      end
    end

    context 'with a random data type' do

      it 'should return EspResponseLoading::Loader' do
        expect(Loader.determine_loading_class('non osp','random data type name')).to eq(EspResponseLoading::Loader)
      end
    end

    context 'with the string "osp"' do

      it 'should return EspResponseLoading::Loader' do
        expect(Loader.determine_loading_class('non osp','osp')).to eq(EspResponseLoading::Loader)
      end
    end

    context 'with a census data type and osp_form source' do

      before { allow(Loader).to receive(:census_data_type?).and_return(true) }

      it 'should return CensusLoading::Loader' do
        expect(Loader.determine_loading_class('osp_form','data type name')).to eq(CensusLoading::Loader)
      end
    end

    context 'with a school data type and osp_form source' do

      it 'should return SchoolLoading::Loader' do
        expect(Loader.determine_loading_class('osp_form','street')).to eq(SchoolLoading::Loader)
      end
    end


    context 'with a random data type and osp_form source ' do

      it 'should return EspResponseLoading::Loader' do
        expect(Loader.determine_loading_class('osp_form','random data type name')).to eq(EspResponseLoading::Loader)
      end
    end


  end
end
require 'spec_helper'

describe CensusDataSet do

  subject(:census_data_set) { CensusDataSet.new }

  it { should respond_to(:school_value) }

  context 'new data set' do
    before do
      @data_set = FactoryGirl.build(:census_data_set)
    end

    it 'should be saveable' do
      expect { @data_set.on_db(:ca).save! }.to change { @data_set.id}.from(NilClass).to(Fixnum)
    end
  end

end
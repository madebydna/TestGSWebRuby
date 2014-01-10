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

  context 'existing data set' do
    before do
      @data_set = FactoryGirl.build(:census_data_set)
      @data_set.on_db(:ca).save!
    end


    it 'should not be deleteable' do
      expect { @data_set.on_db(:ca).destroy }.to raise_exception(ActiveRecord::ReadOnlyRecord)
    end

    it 'should not be saveable' do
      expect { @data_set.on_db(:ca).save! }.to raise_exception(ActiveRecord::ReadOnlyRecord)
    end
  end



end
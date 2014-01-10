require 'spec_helper'

describe CensusDataSet do

  subject(:census_data_set) { CensusDataSet.new }

  it { should respond_to(:school_value) }

  context 'new data set' do
    subject(:data_set) { FactoryGirl.build(:census_data_set) }

    it 'should be saveable' do
      expect { data_set.on_db(:ca).save! }.to change { data_set.id}.from(NilClass).to(Fixnum)
    end
  end

  context 'existing data set' do
    subject(:data_set) { FactoryGirl.build(:census_data_set) }

    it 'should not be deleteable' do
      data_set.on_db(:ca).save!
      expect { data_set.on_db(:ca).destroy }.to raise_exception(ActiveRecord::ReadOnlyRecord)
    end

    it 'should not be saveable' do
      data_set.on_db(:ca).save!
      expect { data_set.on_db(:ca).save! }.to raise_exception(ActiveRecord::ReadOnlyRecord)
    end
  end



end
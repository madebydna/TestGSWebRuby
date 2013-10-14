require 'spec_helper'

describe CensusDataSet do

  subject(:census_data_set) { CensusDataSet.new }

  it { should respond_to(:school_value) }

  context 'new data set' do
    subject(:data_set) { FactoryGirl.build(:census_data_set) }

    it 'should be saveable' do
      expect { data_set.save! }.to change { data_set.id}.from(NilClass).to(Fixnum)
    end
  end

  context 'existing data set' do
    subject(:data_set) { FactoryGirl.create(:census_data_set) }

    it 'should not be deleteable' do
      expect { data_set.destroy }.to raise_exception(ActiveRecord::ReadOnlyRecord)
    end

    it 'should not be saveable' do
      expect { data_set.save! }.to raise_exception(ActiveRecord::ReadOnlyRecord)
    end
  end








end
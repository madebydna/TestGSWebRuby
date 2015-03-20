require 'spec_helper'

describe CensusDataResults do

  describe '#keep_null_breakdowns!' do
    let(:null_breakdowns) do
      [
        FactoryGirl.build(
          :census_data_set,
          breakdown_id: nil,
          data_type_id: 1
        ),
        FactoryGirl.build(
          :census_data_set,
          breakdown_id: nil,
          data_type_id: 2
        )
      ]
    end
    let(:non_null_breakdowns) do
      [
        FactoryGirl.build(
          :census_data_set,
          breakdown_id: 1,
          data_type_id: 1
        ),
        FactoryGirl.build(
          :census_data_set,
          breakdown_id: 1,
          data_type_id: 2
        )
      ]
    end

    it 'should remove data sets with non-null breakdowns if there are data \
sets with null breakdowns' do
      results = CensusDataResults.new(
        (null_breakdowns + non_null_breakdowns).shuffle
      )
      results.keep_null_breakdowns!
      expect(results).to include(*null_breakdowns)
      expect(results).to_not include(*non_null_breakdowns)
    end

    it 'should not remove any data sets if they all have non-null breakdown' do
      results = CensusDataResults.new(non_null_breakdowns.shuffle)
      results.keep_null_breakdowns!
      expect(results).to include(*non_null_breakdowns)
      expect(results.size).to eq non_null_breakdowns.size
    end

    it 'should not remove any data sets if they all have null breakdown' do
      results = CensusDataResults.new(null_breakdowns.shuffle)
      results.keep_null_breakdowns!
      expect(results).to include(*null_breakdowns)
      expect(results.size).to eq null_breakdowns.size
    end
  end

  describe '#sort_school_value_desc_by_date_type!' do
    it 'should sort by school value in descending order' do

      data = [
        FactoryGirl.build(
          :census_data_set,
          :with_school_value,
          school_value_float: 3
        ),
        FactoryGirl.build(
          :census_data_set,
          :with_school_value,
          school_value_float: 1
        ),
        FactoryGirl.build(
          :census_data_set,
          :with_school_value,
          school_value_float: 2
        ),
      ]

      results = CensusDataResults.new(data.shuffle)
      results.sort_school_value_desc_by_date_type!
      expect(results.map(&:school_value)).to eq([3.0, 2.0, 1.0])
    end
  end

  describe '#for_data_types' do
    let(:census_data_set_1) { FactoryGirl.build(:census_data_set) }
    let(:census_data_set_2) { FactoryGirl.build(:census_data_set) }
    let(:census_data_set_3) { FactoryGirl.build(:census_data_set) }
    let(:data_sets) do
      [
        census_data_set_1, census_data_set_2, census_data_set_3
      ]
    end
    subject { CensusDataResults.new(data_sets) }

    before(:each) do
      allow(census_data_set_1).to receive(:census_data_type) do
        FactoryGirl.build(:census_data_type, id: 9, description: 'test description')
      end
      allow(census_data_set_2).to receive(:census_data_type) do
        FactoryGirl.build(:census_data_type, id: 10)
      end
      allow(census_data_set_3).to receive(:census_data_type) do
        FactoryGirl.build(:census_data_type, id: 11)
      end
    end

    it 'should select data types by description' do
      expect(subject.for_data_types(['test description']).results)
        .to eq [census_data_set_1]
    end

    it 'should select data types by id' do
      expect(subject.for_data_types([10]).results)
        .to eq [census_data_set_2]
    end

    it 'should select data types by an ID that is a string' do
      expect(subject.for_data_types(['11']).results)
        .to eq [census_data_set_3]
    end
  end

  describe '#max_year_per_data_type' do
    let(:data_sets) do
      data_sets = (1..3).map do |id| FactoryGirl.build_stubbed(
          :census_data_set,
          id: id,
          data_type_id: 1,
          year: 2000 - id
        )
      end +
      (4..5).map do |id| FactoryGirl.build_stubbed(
          :census_data_set,
          id: id,
          data_type_id: 2,
          year: 2010 - id
        )
      end
      data_sets.each do |data_set|
        allow(data_set).to receive(:census_data_school_values).and_return(FactoryGirl.build_stubbed_list(:census_data_school_value, 1))
      end
      data_sets
    end

    subject { CensusDataResults.new(data_sets) }

    it 'generates a hash with latest year for each data type' do
      expect(subject.max_year_per_data_type).to eq(1 => 1999, 2 => 2006)
    end
  end

  describe '#filter_to_max_year_per_data_type!' do
    let(:data_sets) do
      data_sets = (1..3).map do |id| FactoryGirl.build_stubbed(
          :census_data_set,
          id: id,
          data_type_id: 1,
          year: 2000 - id
        )
      end +
      (4..5).map do |id| FactoryGirl.build_stubbed(
          :census_data_set,
          id: id,
          data_type_id: 2,
          year: 2010 - id
        )
      end
      data_sets.each do |data_set|
        allow(data_set).to receive(:census_data_school_values).and_return(FactoryGirl.build_stubbed_list(:census_data_school_value, 1))
      end
      data_sets
    end

    subject { CensusDataResults.new(data_sets) }

    it 'removes data sets that are the latest for their data type' do
      result = subject.filter_to_max_year_per_data_type!
      expect(result.map(&:id)).to eq [1, 4]
    end
  end
end

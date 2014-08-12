require 'spec_helper'

describe CensusDataReader do
  let(:page) { double('page') }
  let(:school) { FactoryGirl.build(:school) }
  subject(:reader) { CensusDataReader.new(school) }

  before(:each) do
    allow(school).to receive(:page).and_return page
  end

  describe 'census_data_by_data_type_query' do
    it 'should find out all possible configured census data types' do
      allow(CensusDataSetQuery).to receive(:new).and_return double('query').as_null_object
      expect(page).to receive(:all_configured_keys).with('census_data')
      expect(page).to receive(:all_configured_keys).with('census_data_points')
      subject.send :census_data_by_data_type_query
    end

    it 'should return a query' do
      allow(page).to receive(:all_configured_keys).and_return [1]
      result = subject.send :census_data_by_data_type_query
      expect(result).to be_a CensusDataSetQuery
    end
  end

  describe '#raw_data' do
    it 'should query using all census data types' do
      pending
      query_object = double('query_object')
      allow(page).to receive(:all_configured_keys).and_return(%w(a b c))
      allow(CensusDataForSchoolQuery).to receive(:new).and_return query_object
      expect(query_object).to receive(:latest_data_for_school).with(%w(a b c))
      subject.send :raw_data
    end

    it 'should memoize the result' do
      result = { blah: 123 }
      subject.instance_variable_set :@all_census_data, result
      expect(subject.send :raw_data).to eq(result)
    end
  end

  describe '#raw_data_for_category' do
    it 'should filter down to data for only this category' do
      category = double('category')
      data = double('data')
      allow(category).to receive(:keys).and_return(%w(a b c))
      allow(subject).to receive(:raw_data).and_return data
      expect(data).to receive(:for_data_types).with(%w(a b c))
      subject.send :raw_data_for_category, category
    end
  end

  describe '#sort_based_on_config' do
    let(:category) { double('category') }

    before do
      allow(category).to receive(:keys).and_return %w(a b c)
    end

    it 'should sort based on config data' do
      hash =  {
        'b' => nil,
        'a' => nil,
        'c' => nil
      }
      expected = {
        'a' => nil,
        'b' => nil,
        'c' => nil
      }
      expect((subject.send :sort_based_on_config, hash, category).to_s)
        .to eq(expected.to_s)
    end

    it 'should maintain sort order if no info in config' do
      allow(category).to receive(:keys).and_return []
      hash =  {
        'b' => nil,
        'a' => nil,
        'c' => nil
      }
      expect((subject.send :sort_based_on_config, hash, category).to_s)
        .to eq(hash.to_s)
    end

    it 'should ignore items that arent in config (should handle nils)' do
      hash =  {
        'c' => nil,
        'd' => nil,
        'b' => nil
      }
      expected =  {
        'b' => nil,
        'd' => nil,
        'c' => nil
      }
      expect((subject.send :sort_based_on_config, hash, category).to_s)
        .to eq(expected.to_s)
    end
  end

  describe '#labelize_hash_keys' do
    it 'should handle empty lookup table' do
      input = {
        'a' => nil
      }
      expect(subject.send :labelize_hash_keys, input, {}).to eq(input)
    end

    it 'should transform keys' do
      input = {
        'a' => nil
      }
      lookup_hash = {
        'a' => 'blah'
      }
      expected = {
        'blah' => nil
      }
      expect(subject.send :labelize_hash_keys, input, lookup_hash)
        .to eq(expected)
    end

  end

  describe '#build_data_type_descriptions_to_hashes_map' do

    it 'should only include items that have school value or state value' do
      data_set_with_school_and_state_values =
        FactoryGirl.build(
          :census_data_set,
          :with_school_value,
          :with_state_value
        )

      data_set_without_school_value =
        FactoryGirl.build(:census_data_set, :with_state_value)

      data_set_without_state_value =
        FactoryGirl.build(:census_data_set, :with_school_value)

      data_set_without_state_value_or_school_value =
        FactoryGirl.build(:census_data_set)

      hash = {
        'a' => [
          data_set_with_school_and_state_values,
          data_set_without_school_value,
          data_set_without_state_value
        ],
        'b' => [
          data_set_without_state_value_or_school_value
        ]
      }

      result = subject.send :build_data_type_descriptions_to_hashes_map, hash

      expect(result['b']).to be_empty
      expect(result['a'].size).to eq 3
    end

    it 'chooses the breakdown description if config entry breakdown not set' do
      data_set_with_config_entry_label =
        FactoryGirl.build(:census_data_set, :with_school_value)

      data_set_without_config_entry_label =
        FactoryGirl.build(:census_data_set, :with_school_value)


      allow(data_set_with_config_entry_label).to receive(:config_entry_breakdown_label).and_return 'a label'
      allow(data_set_without_config_entry_label).to receive(:config_entry_breakdown_label).and_return nil
      allow(data_set_without_config_entry_label).to receive(:census_breakdown).and_return 'a different label'

      hash = {
        'foo' => [
          data_set_with_config_entry_label,
          data_set_without_config_entry_label
        ]
      }

      result = subject.send :build_data_type_descriptions_to_hashes_map, hash
      expect(result['foo']).to be_present
      expect(result['foo'].first[:breakdown]).to eq 'a label'
      expect(result['foo'].last[:breakdown]).to eq 'a different label'
    end

    it 'should set the year to the manual override (school modified) year' do
      data_set_a = FactoryGirl.build(
        :manual_override_data_set,
        :with_school_value,
        school_value_modified: '2000-01-01'
      )

      hash = {
        'foo' => [data_set_a]
      }

      result = subject.send :build_data_type_descriptions_to_hashes_map, hash
      expect(result['foo'].first[:year]).to eq 2000
    end
  end

  describe '#labels_to_hashes_map' do
    it 'should respond to method call' do
      expect(subject).to respond_to(:labels_to_hashes_map)
    end
  end

  describe 'a spec to test sample data code' do
    it 'should not fail' do
      require 'sample_data_helper'
      load_sample_data 'census/name_of_a_test'
      expect(true).to be_truthy
    end
  end

  describe '#labels_to_hashes_map' do
    let(:data) do
      FactoryGirl.build_stubbed_list(:census_data_set, 2, data_type_id: 1)
    end

    it 'should memoize the result' do
      expect(subject).to receive(:raw_data_for_category).once.and_return data
      subject.labels_to_hashes_map(FactoryGirl.build_stubbed(:category))
    end
  end

  describe '#footnotes_for_category' do
    let(:data) do
      {
        'Ethnicity' => [
          {
            breakdown: 'White',
            school_value: 42.1053,
            district_value: nil,
            state_value: 71.4284,
            source: 'CA Dept. of Education',
            year: 2011
          },
          {
            breakdown: 'African-American',
            school_value: 42.1053,
            district_value: nil,
            state_value: 71.4284,
            source: 'A different source',
            year: 1999
          }
        ]
      }
    end
    let(:category) { FactoryGirl.build_stubbed(:category) }
    let(:result) do
      subject.footnotes_for_category(category)
    end
    before(:each) do
      allow(subject).to receive(:labels_to_hashes_map).and_return data
    end

    it 'should build footnotes using the data type\'s first source' do
      expect(result).to eq([
        {
          source: 'CA Dept. of Education',
          year: 2011
        }
      ])
    end

    it 'should ignore empty values' do
      expected = [
        {
          source: 'CA Dept. of Education',
          year: 2011
        }
      ]
      data[:key_with_no_values] = nil
      expect(result).to eq expected
      data[:key_with_no_values] = []
      result = subject.footnotes_for_category(category)
      expect(result).to eq expected
    end
  end
end
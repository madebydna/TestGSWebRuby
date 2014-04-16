require 'spec_helper'

describe CensusDataReader do
  let(:page) { double('page') }
  let(:school) { FactoryGirl.build(:school) }
  subject(:reader) { CensusDataReader.new(school) }

  before(:each) do
    school.stub(:page).and_return page
  end


  describe '#raw_data' do
    it 'should find out all possible configured census data types' do
      CensusDataForSchoolQuery.stub(:new).and_return double('query').as_null_object
      expect(page).to receive(:all_configured_keys).with('census_data')
      subject.send :raw_data
    end

    it 'should query using all census data types' do
      query_object = double('query_object')
      page.stub(:all_configured_keys).and_return(%w[a b c])
      CensusDataForSchoolQuery.stub(:new).and_return query_object
      expect(query_object).to receive(:latest_data_for_school).with(%w[a b c])
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
      category.stub(:keys).and_return(%w[a b c])
      subject.stub(:raw_data).and_return data
      expect(data).to receive(:for_data_types).with(%w[a b c])
      subject.send :raw_data_for_category, category
    end
  end

  describe '#sort_based_on_config' do
    let(:category) { double('category') }

    before do
      category.stub(:keys).and_return %w[a b c]
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
      expect((subject.send :sort_based_on_config, hash, category).to_s).to eq(expected.to_s)
    end

    it 'should sort and be case insensitive' do
      category.stub(:keys).and_return %w[A B C]
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
      expect((subject.send :sort_based_on_config, hash, category).to_s).to eq(expected.to_s)
    end

    it 'should maintain sort order if no info in config' do
      category.stub(:keys).and_return []
      hash =  {
        'b' => nil,
        'a' => nil,
        'c' => nil
      }
      expect((subject.send :sort_based_on_config, hash, category).to_s).to eq(hash.to_s)
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
      expect((subject.send :sort_based_on_config, hash, category).to_s).to eq(expected.to_s)
    end
  end

  describe '#keep_null_breakdowns' do
    let(:null_breakdown_data_set) { double }
    let(:non_null_breakdown_data_set) { double }

    before do
      null_breakdown_data_set.stub(:breakdown_id).and_return nil
      non_null_breakdown_data_set.stub(:breakdown_id).and_return 1
    end

    it 'should remove data sets with non-null breakdowns if null breakdown present' do
      hash = {
        'a' => [
          null_breakdown_data_set,
          null_breakdown_data_set,
          non_null_breakdown_data_set,
          non_null_breakdown_data_set
        ]
      }
      expected = {
        'a' => [
          null_breakdown_data_set,
          null_breakdown_data_set,
        ]
      }
      subject.send :keep_null_breakdowns!, hash
      expect(hash).to eq(expected)
    end

    it 'should not remove any data sets if they all have non-null breakdown' do
      hash = {
        'a' => [
          non_null_breakdown_data_set,
          non_null_breakdown_data_set
        ]
      }
      expected = hash.dup
      subject.send :keep_null_breakdowns!, hash
      expect(hash).to eq(expected)
    end

    it 'should not remove any data sets if they all have null breakdown' do
      hash = {
        'a' => [
          null_breakdown_data_set,
          null_breakdown_data_set
        ]
      }
      expected = hash.dup
      subject.send :keep_null_breakdowns!, hash
      expect(hash).to eq(expected)
    end
  end

  describe '#prettify_hash' do
    it 'should handle empty lookup table' do
      input = {
        'a' => nil
      }
      expect(subject.send :prettify_hash, input, {}).to eq(input)
    end

    it 'should transform keys' do
      input = {
        'a' => nil
      }
      lookup_hash= {
        'a' => 'blah'
      }
      expected = {
        'blah' => nil
      }
      expect(subject.send :prettify_hash, input, lookup_hash).to eq(expected)
    end

  end

  describe '#build_data_type_descriptions_to_hashes_map' do

    it 'should only include items that have school value or state value' do
      data_set_with_school_and_state_values = FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 10),
        census_data_state_values: FactoryGirl.build_list(:census_data_state_value, 1, value_float: 10)
      )

      data_set_without_school_value = FactoryGirl.build(:census_data_set,
        census_data_state_values: FactoryGirl.build_list(:census_data_state_value, 1, value_float: 10)
      )

      data_set_without_state_value =  FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 10),
      )

      data_set_without_state_value_or_school_value =  FactoryGirl.build(:census_data_set)

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

      expected = {
        'a' => [
          {
            breakdown: nil,
            school_value: 10.0,
            district_value: nil,
            state_value: nil,
            source: nil,
            year: 2011
          },
          {
            breakdown: nil,
            school_value: 10.0,
            district_value: nil,
            state_value: 10.0,
            source: nil,
            year: 2011
          },
          {
            breakdown: nil,
            school_value: nil,
            district_value: nil,
            state_value: 10.0,
            source: nil,
            year: 2011
          }
        ],
        'b' => []
      }

      expect(subject.send :build_data_type_descriptions_to_hashes_map, hash).to eq(expected)
    end

    it 'should sort by school value in descending order' do
      data_set_a = FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 1)
      )

      data_set_b =  FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 2),
      )

      hash = {
        'a' => [ data_set_a, data_set_b ]
      }
      expected = {
        'a' => [
          {
            breakdown: nil,
            school_value: 2.0,
            district_value: nil,
            state_value: nil,
            source: nil,
            year: 2011
          },
          {
            breakdown: nil,
            school_value: 1.0,
            district_value: nil,
            state_value: nil,
            source: nil,
            year: 2011
          }
        ]
      }

      expect(subject.send :build_data_type_descriptions_to_hashes_map, hash).to eq(expected)
    end

    it 'should choose the breakdown description if config entry breakdown not set' do
      data_set_with_config_entry_label = FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 2)
      )
      data_set_without_config_entry_label = FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 1)
      )
      data_set_with_config_entry_label.stub(:config_entry_breakdown_label).and_return 'a label'
      data_set_without_config_entry_label.stub(:config_entry_breakdown_label).and_return nil
      data_set_without_config_entry_label.stub(:census_breakdown).and_return 'a different label'

      hash = {
        'a' => [ data_set_with_config_entry_label, data_set_without_config_entry_label ]
      }

      expected = {
        'a' => [
          {
            breakdown: 'a label',
            school_value: 2.0,
            district_value: nil,
            state_value: nil,
            source: nil,
            year: 2011
          },
          {
            breakdown: 'a different label',
            school_value: 1.0,
            district_value: nil,
            state_value: nil,
            source: nil,
            year: 2011
          }
        ]
      }

      expect(subject.send :build_data_type_descriptions_to_hashes_map, hash).to eq(expected)

    end

    it 'should set the year to the manual override (school modified) year' do
      data_set_a = FactoryGirl.build(:census_data_set,
        year: 0,
        census_data_school_values: FactoryGirl.build_list(
          :census_data_school_value,
          1,
          value_float: 1,
          modified: Time.zone.parse('2000-01-01')
        )
      )

      hash = {
        'a' => [ data_set_a ]
      }
      expected = {
        'a' => [
          {
            breakdown: nil,
            school_value: 1.0,
            district_value: nil,
            state_value: nil,
            source: nil,
            year: 2000
          },
        ]
      }

      expect(subject.send :build_data_type_descriptions_to_hashes_map, hash).to eq(expected)
    end
  end

  describe '#data_type_descriptions_to_school_values_map' do

    it 'should build a hash with correct keys and values' do
      data_set_with_school_and_state_values = FactoryGirl.build(:census_data_set,
        census_data_school_values: FactoryGirl.build_list(:census_data_school_value, 1, value_float: 10),
        census_data_state_values: FactoryGirl.build_list(:census_data_state_value, 1, value_float: 10),
      )
      data_set_with_school_and_state_values.stub(:census_data_type).and_return FactoryGirl.build(
        :census_data_type, description: 'data type desc'
      )

      raw_data = [
        data_set_with_school_and_state_values
      ]
      subject.stub(:raw_data).and_return raw_data

      expected = {
        'data type desc' => 10.0
      }

      expect(subject.data_type_descriptions_to_school_values_map).to eq(expected)
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
      expect(true).to be_true
    end
  end

end




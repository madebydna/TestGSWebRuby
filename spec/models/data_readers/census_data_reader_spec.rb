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

  describe 'a spec to test sample data code' do
    it 'should not fail' do
      require 'sample_data_helper'
      load_sample_data 'census/name_of_a_test'
      expect(true).to be_truthy
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

  describe '#labels_to_hashes_map' do
    let(:category) { FactoryGirl.build(:category, name:'Class size') }

    let(:all_data) do
        {
          "Class size"=>[
            {
              :year=>2014,
              :source=>"DE Dept. of Education",
              :subject=>"English Language Arts",
              :school_value=>21.0,
              :state_average=>19.0
            },
            {
              :year=>2013,
              :source=>"DE Dept. of Education",
              :subject=>"English Language Arts",
              :school_value=>18.0,
              :state_average=>17.0
            },
            {
             :year=>2014,
             :source=>"DE Dept. of Education",
             :subject=>"Math",
             :school_value=>17.0,
             :state_average=>20.0
            }
          ],
          'Ethnicity' => [
            {
              breakdown: 'White',
              school_value: 42.1053,
              district_value: nil,
              state_value: 71.4284,
              source: 'CA Dept. of Education',
              year: 2011
            }
          ]
        }.symbolize_keys
    end

    let(:results_hash) do
      {
        "Class size"=>[
          {
            :year=>2014,
            :source=>"DE Dept. of Education",
            :subject=>"English Language Arts",
            :school_value=>21.0,
            :state_average=>19.0,
            :label=>"A label",
            :description=>nil
          },
          {
            :year=>2013,
            :source=>"DE Dept. of Education",
            :subject=>"English Language Arts",
            :school_value=>18.0,
            :state_average=>17.0,
            :label=>"A label",
            :description=>nil
          }
        ]
      }.symbolize_keys
    end

    before do
      allow(subject).to receive(:convert_subject_to_id).with('English Language Arts').and_return(4)
      allow(subject).to receive(:convert_subject_to_id).with('Math').and_return(5)
      allow(CensusDataType).to receive(:data_type_id_for_data_type_label).with("Class size".to_sym).and_return(35)
      allow(CensusDataType).to receive(:data_type_id_for_data_type_label).with("Ethnicity".to_sym).and_return(32)

    end

    it 'should respond to method call' do
      expect(subject).to respond_to(:labels_to_hashes_map)
    end

    it 'should not return any results since there is no data in the cache.' do
      allow(subject).to receive(:cached_data_for_category).and_return({})

      results = subject.labels_to_hashes_map(category)
      expect(results).to eq({})
    end

    context 'with old style census data type ID response_key' do
      before do
        allow(category.category_datas.first).to receive(:response_key).and_return(35) #class size only
      end

      it 'should return data for only for class size and english, since it matches the configuration.' do
        allow(category.category_datas.first).to receive(:subject_id).and_return(4)  # only English Language Arts
        allow(SchoolCache).to receive(:cached_characteristics_data).and_return(all_data)

        results = subject.labels_to_hashes_map(category)
        expect(results).to eq(results_hash)
      end
    end

    context 'with new style census data type name response_key' do
      before do
        allow(category.category_datas.first).to receive(:response_key).and_return('Class size'.to_sym) #class size only
      end

      it 'should return data for only for class size and english, since it matches the configuration.' do
        allow(category.category_datas.first).to receive(:subject_id).and_return(4)  # only English Language Arts
        allow(SchoolCache).to receive(:cached_characteristics_data).and_return(all_data)

        results = subject.labels_to_hashes_map(category)
        expect(results).to eq(results_hash)
      end
    end
  end

end

require 'spec_helper'

describe EspDataReader do
  let(:school) { FactoryGirl.build(:school) }
  subject(:reader) { EspDataReader.new school }

  describe '#data_for_category' do
    let(:category) { FactoryGirl.build(:category) }
    let(:responses_for_category) {
      {
        'key' => %w[foo bar baz],
        'key2' => %w[foo bar baz],
        'key3' => %w[foo bar baz]
      }
    }
    before(:each) do
      allow(reader).to receive(:responses_for_category).and_return responses_for_category
      allow(category).to receive(:key_label_map).and_return({})
    end

    it 'prettifies the response values' do
      expect(reader).to receive(:prettify_response_key_to_responses_hash!).
        with(responses_for_category).
        and_return(responses_for_category)

      reader.data_for_category category
    end

    it 'returns an array of hashes with correct data' do
      expected = [
        { key: 'key',  label: 'key',  value: %w[foo bar baz] },
        { key: 'key2', label: 'key2', value: %w[foo bar baz] },
        { key: 'key3', label: 'key3', value: %w[foo bar baz] }
      ]
      results = reader.data_for_category category
      expect(results).to eq expected
    end

    it 'prettifies the response keys (by adding labels)' do
      key_label_map = {
        'key' => 'foo',
        'key2' => 'bar',
        'key3' => 'bar'
      }
      expected = [
        { key: 'key',  label: 'foo',  value: %w[foo bar baz] },
        { key: 'key2', label: 'bar', value: %w[foo bar baz] },
        { key: 'key3', label: 'bar', value: %w[foo bar baz] }
      ]
      allow(category).to receive(:key_label_map).and_return key_label_map
      results = reader.data_for_category category
      expect(results).to eq expected
    end
  end

  describe '#prettify_response_key_to_responses_hash!' do
    let(:lookup_table) {
      {
        %w[key foo] => 'bar',
        %w[key bar] => 'baz',
        %w[key2 foo] => 'baz'
      }
    }
    let(:hash) {
      hash = {
        'key' => %w[foo bar baz],
        'key2' => %w[foo bar baz],
        'key3' => %w[foo bar baz]
      }
    }

    before(:each) do
      allow(reader).to receive(:esp_lookup_table).and_return lookup_table
    end

    it 'should transform the hash values' do
      expected = {
        'key' => %w[bar baz baz],
        'key2' => %w[baz bar baz],
        'key3' => %w[foo bar baz]
      }

      reader.prettify_response_key_to_responses_hash! hash
      expect(hash).to eq expected
    end

    it 'should handle an empty lookup table' do
      expected = {
        'key' => %w[foo bar baz],
        'key2' => %w[foo bar baz],
        'key3' => %w[foo bar baz]
      }
      lookup_table = {}
      allow(reader).to receive(:esp_lookup_table).and_return lookup_table
      reader.prettify_response_key_to_responses_hash! hash
      expect(hash).to eq expected
    end
  end

  describe '#responses_for_category' do

    let(:category) { FactoryGirl.build(:category) }
    before(:each) do
      allow(reader).to receive(:sort_based_on_config) { |hash, category| hash }
    end

    it 'should retrieve keys for the school\'s collection' do
      allow(school).to receive(:collections).and_return [3]
      expect(category).to receive(:keys).with([3]).and_return %w[foo bar]
      reader.responses_for_category category
    end

    it 'should filter out keys that we don\'t need for given category' do
      allow(category).to receive(:keys).and_return %w[foo bar]
      allow(reader).to receive(:responses_by_key).and_return({
        'foo' => FactoryGirl.build_list(  :esp_response,
                                          2,
                                          response_key: 'foo',
                                          school: school
                                        ),
        'bar' => FactoryGirl.build_list(  :esp_response,
                                          2,
                                          response_key: 'bar',
                                          school: school
                                        ),
        'baz' => FactoryGirl.build_list(  :esp_response,
                                          2,
                                          response_key: 'baz',
                                          school: school
                                        ),
      })
      results = reader.responses_for_category category
      expect(results.keys).to include 'foo'
      expect(results.keys).to include 'bar'
      expect(results.keys).to_not include 'baz'
    end

    it 'should sort the keys based on config' do
      responses_by_key = double('responses_by_key').as_null_object
      allow(category).to receive(:keys).and_return %w[foo bar]
      allow(reader).to receive(:responses_by_key).and_return responses_by_key

      expect(reader).to receive(:sort_based_on_config).with(
        responses_by_key,
        category
      )
      reader.responses_for_category category
    end
  end

  describe '#responses_by_key' do
    it 'should group esp responses by key' do
      allow(reader).to receive(:all_responses).and_return(
        [
          FactoryGirl.build(:esp_response, response_key: 'a', school: school),
          FactoryGirl.build(:esp_response, response_key: 'b', school: school),
          FactoryGirl.build(:esp_response, response_key: 'a', school: school),
        ]
      )
      responses = reader.responses_by_key
      expect(responses.size).to eq 2
      expect(responses['a'].size).to eq 2
      expect(responses['b'].size).to eq 1
    end
  end

  describe '#sort_based_on_config' do
    let(:category) { double('category') }

    before do
      allow(category).to receive(:keys).and_return %w[a b c]
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
      expect((subject.send :sort_based_on_config, hash, category).to_s).
        to eq(expected.to_s)
    end

    it 'should sort and be case insensitive' do
      allow(category).to receive(:keys).and_return %w[A B C]
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
      expect((subject.send :sort_based_on_config, hash, category).to_s).
        to eq(expected.to_s)
    end

    it 'should maintain sort order if no info in config' do
      allow(category).to receive(:keys).and_return []
      hash =  {
        'b' => nil,
        'a' => nil,
        'c' => nil
      }
      expect((subject.send :sort_based_on_config, hash, category).to_s).
        to eq(hash.to_s)
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
      expect((subject.send :sort_based_on_config, hash, category).to_s).
        to eq(expected.to_s)
    end
  end

end

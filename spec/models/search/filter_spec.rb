require 'spec_helper'

describe Filter do

  let(:simple_filter_attributes) { {label: 'all', name: 'you', value: 'need', display_type: 'is', sort_order: 'love'} }
  let(:simple_filter) { Filter.new(simple_filter_attributes) }

  context 'a filter without children' do
    it 'should have a map that is one hash deep' do
      simple_filter.build_map.each do |key, inner_hash|
        inner_hash.each do |inner_key, inner_value|
          expect(inner_value).to_not be_an_instance_of(Hash)
        end
      end
    end

    it 'should have a map that has only one key' do
      expect(simple_filter.build_map.keys.length).to eq(1)
    end
  end

end
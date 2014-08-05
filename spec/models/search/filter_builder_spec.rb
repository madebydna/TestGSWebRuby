require 'spec_helper'
require_relative 'filter_builder_spec_helper'

describe FilterBuilder do
  include FilterBuilderSpecHelper

  let(:blank_filter_attributes) { {label: '', name: '', value: '', display_type: '', filters: '', sort_order: ''} }
  let(:filter_builder) { FilterBuilder.new }

  describe '#initialize' do

    it 'should return a filter object' do
      expect(filter_builder.filters).to be_an_instance_of Filter
    end

  end

  describe '#get_filters' do
    let(:filters_hash) { filter_builder.get_filters}

    it 'should return a well-formed hash' do
      expect(filters_hash[:display_type]).to eq(:blank_container)
      expect(filters_hash).to have_key :filters
    end

    it 'should have three groups with correct display type' do
      3.times do |i|
        i += 1
        expect(filters_hash[:filters]).to have_key("group#{i}".to_sym)
        display_type = filters_hash[:filters]["group#{i}".to_sym][:display_type]
        if i == 1
          expect(display_type).to eq(:filter_column_primary)
        else
          expect(display_type).to eq(:filter_column_secondary)
        end
      end
    end

    it 'should be hash of hash of hash of hash.. aka no other data structure' do
      filter_elements(filters_hash)
    end

    it 'should have :name and :filters keys for each display_type: :title layer' do
      check_title_layers(filters_hash)
    end

    it 'should have :display_type at every layer of the hash' do
      expect(every_layer_has_display_type(filters_hash)).to be_truthy
    end

    it 'the bottom layer should have label, display_type, name and value' do
      filter_elements(filters_hash).each do |filter|
        [:label, :display_type, :name, :value].each do |filter_key|
          expect(filter).to have_key(filter_key)
        end
      end
    end

  end

end

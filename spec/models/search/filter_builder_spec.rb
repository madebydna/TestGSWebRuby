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

  describe '#default_advanced_filters' do
    let(:filters_hash) { filter_builder.default_advanced_filters}

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

    context 'group 1' do
      it 'exists' do
        expect(filters_hash[:filters]).to have_key :group1
      end

      let (:group1_filters) {filters_hash[:filters][:group1][:filters]}

      context 'should contain simple filters' do
        {grade: 'grade', distance: 'distance', st: 'school type'}.each do |k,v|
          it "like #{v}" do
            expect(group1_filters).to have_key k
          end
        end
      end
      context 'should contain advanced filters' do
        {transportation: 'transportation', beforeAfterCare: 'before/after care'}.each do |k,v|
          it "like #{v}" do
            expect(group1_filters).to have_key k
          end
        end
      end
    end
    context 'group 2' do
      it 'exists' do
        expect(filters_hash[:filters]).to have_key :group2
      end
      let (:group2_filters) {filters_hash[:filters][:group2][:filters]}
      context 'should contain advanced filters' do
        {dress_code: 'dress code', class_offerings: 'class offerings', sports: 'sports'}.each do |k,v|
          it "like #{v}" do
            expect(group2_filters).to have_key k
          end
        end
      end
    end
    context 'group 3' do
      it 'exists' do
        expect(filters_hash[:filters]).to have_key :group3
      end
      let (:group3_filters) {filters_hash[:filters][:group3][:filters]}
      context 'should contain advanced filters' do
        {school_focus: 'school focus'}.each do |k,v|
          it "like #{v}" do
            expect(group3_filters).to have_key k
          end
        end
      end
    end
  end

  describe '#default_simple_filters' do
    let(:filters_hash) { filter_builder.default_simple_filters}

    it 'should return a well-formed hash' do
      expect(filters_hash[:display_type]).to eq(:blank_container)
      expect(filters_hash).to have_key :filters
    end

    it 'should have one group with correct display type' do
      expect(filters_hash[:filters]).to have_key(:group1)
      expect(filters_hash[:filters][:group1][:display_type]).to eq(:filter_column_primary)
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

    context 'group 1' do
      it 'exists' do
        expect(filters_hash[:filters]).to have_key :group1
      end

      let (:group1_filters) {filters_hash[:filters][:group1][:filters]}

      context 'should contain simple filters' do
        {grade: 'grade', distance: 'distance', st: 'school type'}.each do |k,v|
          it "like #{v}" do
            expect(group1_filters).to have_key k
          end
        end
      end
      context 'should not contain advanced filters' do
        {transportation: 'transportation', beforeAfterCare: 'before/after care'}.each do |k,v|
          it "like #{v}" do
            expect(group1_filters).to_not have_key k
          end
        end
      end
    end
    context 'group 2' do
      it 'does not exist' do
        expect(filters_hash[:filters]).to_not have_key :group2
      end
    end
    context 'group 3' do
      it 'does not exist' do
        expect(filters_hash[:filters]).to_not have_key :group3
      end
    end
  end

  describe '#cache_key' do
    context 'in any non-Local region of the country' do
      let (:cache_key) { FilterBuilder.new('', '', false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('', '', true).filters.cache_key }
      it 'should represent a simple filter configuration if forced' do
        expect(forced_simple).to eq('simple_v1')
      end
      it 'should represent a simple filter configuration even if not forced' do
        expect(cache_key).to eq('simple_v1')
      end
    end
    context 'in Delaware' do
      let (:de_cache_key) { FilterBuilder.new('de', nil, false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('de', nil, true).filters.cache_key }
      it 'should represent a default advanced filter configuration' do
        expect(de_cache_key).to eq('advanced_v1')
      end
      it 'should represent a simple configuration if forced' do
        expect(forced_simple).to eq('simple_v1')
      end
    end
    context 'in Indiana' do
      let (:in_cache_key) { FilterBuilder.new('in', nil, false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('in', nil, true).filters.cache_key }
      it 'should represent a vouchers configuration' do
        expect(in_cache_key).to eq('vouchers_v1')
      end
      it 'should represent a simple configuration if forced' do
        expect(forced_simple).to eq('simple_v1')
      end
    end
    context 'in Detroit, MI' do
      let (:detroit_cache_key) { FilterBuilder.new('mi', 'Detroit', false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('mi', 'Detroit', true).filters.cache_key }
      it 'should represent a college readiness configuration' do
        expect(detroit_cache_key).to eq('college_readiness_v1')
      end
      it 'should represent a simple configuration if forced' do
        expect(forced_simple).to eq('simple_v1')
      end
    end
  end
end

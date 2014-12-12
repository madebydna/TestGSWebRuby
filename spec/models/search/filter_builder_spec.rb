require 'spec_helper'
require_relative 'filter_builder_spec_helper'

def assert_filter_structure(filter_map, index)
  it "should have panel #{index+1}" do
    expect(filters.filters.length).to be > index
  end
  context "panel #{index+1}" do
    filter_map[:contains].each do |filter_name|
      it "should contain #{filter_name}" do
        filter_names = filters.filters[index].filters.collect {|f| [*f.name]}.flatten
        expect(filter_names).to include(filter_name)
      end
    end
    filter_map[:does_not_contain].each do |filter_name|
      it "should not contain #{filter_name}" do
        filter_names = filters.filters[index].filters.collect {|f| [*f.name]}.flatten
        expect(filter_names).to_not include(filter_name)
      end
    end
  end
end

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

  describe '#filters_with_callbacks' do
    context 'in Delaware' do
      let (:filters) { FilterBuilder.new('DE', nil, false).filters }
      [ { panel: 1,
          contains: [:grades, :distance, :st, :transportation, :beforeAfterCare],
          does_not_contain: [:cgr, :dress_code, :class_offerings, :boys_sports, :girls_sports, :school_focus]
        },
          {panel: 2,
          contains: [:dress_code, :class_offerings, :boys_sports, :girls_sports],
          does_not_contain: [:grades, :distance, :st, :transportation, :beforeAfterCare, :school_focus, :enrollment]
        },
          {panel: 3,
          contains: [:school_focus],
          does_not_contain: [:enrollment, :grades, :distance, :st, :transportation, :beforeAfterCare, :dress_code, :class_offerings, :boys_sports, :girls_sports]
      }].each_with_index do |filter_map, index|
        assert_filter_structure(filter_map, index)
      end
    end
    context 'in Indiana' do
      let (:filters) { FilterBuilder.new('IN', nil, false).filters }
      [ { panel: 1,
          contains: [:grades, :distance, :st, :transportation, :beforeAfterCare],
          does_not_contain: [:cgr]
        },
        { panel: 2,
          contains: [:dress_code, :class_offerings, :boys_sports, :girls_sports],
          does_not_contain: []
        },
        { panel: 3,
          contains: [:school_focus, :enrollment],
          does_not_contain: []
      }].each_with_index do |filter_map, index|
        assert_filter_structure(filter_map, index)
      end
    end
    context 'in Michigan' do
      let (:filters) { FilterBuilder.new('MI', nil, false).filters }
      [ { panel: 1,
          contains: [:grades, :distance, :st],
          does_not_contain: [:cgr, :transportation, :beforeAfterCare]
      }].each_with_index do |filter_map, index|
        assert_filter_structure(filter_map, index)
      end
      it 'does not have panel 2 or 3' do
        expect(filters.filters.length).to eq(1)
      end
    end
    context 'in Detroit, MI' do
      let (:filters) { FilterBuilder.new('MI', 'Detroit', false).filters }
      [ { panel: 1,
          contains: [:grades, :distance, :st, :cgr, :transportation, :beforeAfterCare],
          does_not_contain: []
        },
        { panel: 2,
          contains: [:dress_code, :class_offerings, :boys_sports, :girls_sports],
          does_not_contain: []
        },
        { panel: 3,
          contains: [:school_focus],
          does_not_contain: [:enrollment]
      }].each_with_index do |filter_map, index|
        assert_filter_structure(filter_map, index)
      end
    end
    context 'in Wisconsin' do
      let (:filters) { FilterBuilder.new('WI', nil, false).filters }
      [ { panel: 1,
          contains: [:grades, :distance, :st],
          does_not_contain: [:cgr, :transportation, :beforeAfterCare]
      }].each_with_index do |filter_map, index|
        assert_filter_structure(filter_map, index)
      end
      it 'does not have panel 2 or 3' do
        expect(filters.filters.length).to eq(1)
      end
    end
    context 'in Milwaukee, WI' do
      let (:filters) { FilterBuilder.new('WI', 'Milwaukee', false).filters }
      [ { panel: 1,
          contains: [:grades, :distance, :st, :transportation, :beforeAfterCare],
          does_not_contain: [:cgr]
        },
        { panel: 2,
          contains: [:dress_code, :class_offerings, :boys_sports, :girls_sports],
          does_not_contain: []
        },
        { panel: 3,
          contains: [:school_focus, :enrollment],
          does_not_contain: [:class_offerings]
      }].each_with_index do |filter_map, index|
        assert_filter_structure(filter_map, index)
      end
    end

  end

  describe '#cache_key' do
    context 'in any non-Local region of the country' do
      let (:cache_key) { FilterBuilder.new('', '', false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('', '', true).filters.cache_key }
      it 'should represent a simple filter configuration if forced' do
        expect(forced_simple).to start_with('simple')
      end
      it 'should represent a simple filter configuration even if not forced' do
        expect(cache_key).to start_with('simple')
      end
    end
    context 'in Delaware' do
      let (:de_cache_key) { FilterBuilder.new('de', nil, false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('de', nil, true).filters.cache_key }
      it 'should represent a default advanced filter configuration' do
        expect(de_cache_key).to start_with('advanced')
      end
      it 'should represent a simple configuration if forced' do
        expect(forced_simple).to start_with('simple')
      end
    end
    context 'in Indiana' do
      let (:in_cache_key) { FilterBuilder.new('in', nil, false).filters.cache_key }
      let (:forced_simple) { FilterBuilder.new('in', nil, true).filters.cache_key }
      context 'in Indianapolis' do
        let (:indy_cache_key) { FilterBuilder.new('in', 'Indianapolis', false).filters.cache_key }
        it 'should represent a vouchers configuration' do
          expect(indy_cache_key).to start_with('vouchers')
        end
      end
      it 'should represent a vouchers configuration' do
        expect(in_cache_key).to start_with('vouchers')
      end
      it 'should represent a simple configuration if forced' do
        expect(forced_simple).to start_with('simple')
      end
    end
    context 'in Michigan' do
      let (:mi_cache_key) { FilterBuilder.new('mi', nil, false).filters.cache_key }
      context 'in Detroit' do
        let (:detroit_cache_key) { FilterBuilder.new('mi', 'Detroit', false).filters.cache_key }
        let (:forced_simple) { FilterBuilder.new('mi', 'Detroit', true).filters.cache_key }
        it 'should represent a college readiness configuration' do
          expect(detroit_cache_key).to start_with('college_readiness')
        end
        it 'should represent a simple configuration if forced' do
          expect(forced_simple).to start_with('simple')
        end
      end
      it 'should represent a simple configuration' do
        expect(mi_cache_key).to start_with('simple')
      end
    end
    context 'in Wisconsin' do
      let (:wi_cache_key) { FilterBuilder.new('wi', nil, false).filters.cache_key }
      context 'in Milwaukee' do
        let (:mke_cache_key) { FilterBuilder.new('wi', 'Milwaukee', false).filters.cache_key }
        let (:forced_simple) { FilterBuilder.new('wi', 'Milwaukee', true).filters.cache_key }
        it 'should represent a vouchers configuration' do
          expect(mke_cache_key).to start_with('vouchers')
        end
        it 'should represent a simple configuration if forced' do
          expect(forced_simple).to start_with('simple')
        end
      end
      it 'should represent a simple configuration' do
        expect(wi_cache_key).to start_with('simple')
      end
    end
  end
end

require 'spec_helper'

describe SearchHelper do

  describe '#guided_search_path' do
    HubStruct = Struct.new(:state, :city)
    it 'should handle single word states' do
      single_word_state_hub_hub = HubStruct.new('Indiana')
      expect(guided_search_path(single_word_state_hub_hub)).to eq('/indiana/guided-search')
    end

    it 'should handle single word cities' do
      single_word_city_hub_hub = HubStruct.new('Indiana', 'Indianapolis')
      expect(guided_search_path(single_word_city_hub_hub)).to eq('/indiana/indianapolis/guided-search')
    end

    it 'should handle multi-word states' do
      multi_word_state_hub = HubStruct.new('North Dakota')
      expect(guided_search_path(multi_word_state_hub)).to eq('/north-dakota/guided-search')
    end

    it 'should handle multi-word cities' do
      multi_word_city_hub = HubStruct.new('Oklahoma', 'Oklahoma City')
      expect(guided_search_path(multi_word_city_hub)).to eq('/oklahoma/oklahoma-city/guided-search')
    end

    it 'should handle multi-word cities in multi-word states' do
      all_the_words_multi_hub = HubStruct.new('New York', 'New York City')
      expect(guided_search_path(all_the_words_multi_hub)).to eq('/new-york/new-york-city/guided-search')
    end
  end

end

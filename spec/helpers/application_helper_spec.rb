require 'spec_helper'

describe ApplicationHelper do
  describe '#category_placement_anchor' do
    let(:category_placement) {
      FactoryGirl.build(:category_placement, id: 1, title: 'A title', category: FactoryGirl.build(:category))
    }

    it 'should use the category placement title if available' do
      expect(helper.category_placement_anchor(category_placement)).to eq 'A_title'
    end

    it 'should use the category name if there is no title' do
      category_placement.title = nil
      expect(helper.category_placement_anchor(category_placement)).to eq 'Test_category'
    end
  end

  describe '#draw_stars' do
    describe 'should return html with correct on and off class values' do
      it 'should draw both color stars' do
        html = helper.draw_stars(16, 1)
        spans = html.split('</span>')
        expect(spans.first).to match /orange/
        expect(spans.first).to_not match /grey/
        expect(spans.last).to match /grey/
        expect(spans.last).to_not match /orange/
      end

      it 'for 1 star on' do
        html = helper.draw_stars(16, 1)
        spans = html.split('</span>')
        expect(spans.first).to match /i-\d+-star-1/
        expect(spans.last).to match /i-\d+-star-4/
      end

      it 'for 0 stars on' do
        html = helper.draw_stars(16, 0)
        spans = html.split('</span>')
        expect(spans.first).to match /i-\d+-star-0/
        expect(spans.last).to match /i-\d+-star-5/
      end

      it 'for 5 stars on' do
        html = helper.draw_stars(16, 5)
        spans = html.split('</span>')
        expect(spans.first).to match /i-\d+-star-5/
        expect(spans.last).to match /i-\d+-star-0/
      end
    end

    it 'should set the right size' do
      html = helper.draw_stars(16, 1)
      spans = html.split('</span>')
      expect(spans.first).to match /i-16-star-\d+/
      expect(spans.last).to match /i-16-star-\d+/
    end
  end

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

  describe '#vimeo_parse_id_from_str' do
    it 'should parse vimeo id from long url' do
      vimeo_id = vimeo_parse_id_from_str('https://vimeo.com/channels/staffpicks/129710408')
      expect(vimeo_id).to eq('129710408')
    end

    it 'should parse vimeo id from short url' do
      vimeo_id = vimeo_parse_id_from_str('https://vimeo.com/129710408')
      expect(vimeo_id).to eq('129710408')
    end
  end

  describe '#create_vimeo_api_url' do
    it 'should insert vimeo video id into api url' do
      vimeo_id = '129710408'
      expect(create_vimeo_api_url(vimeo_id)).to eq('https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/129710408')
    end
  end
end

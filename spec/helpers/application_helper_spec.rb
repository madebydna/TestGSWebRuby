require 'spec_helper'

describe ApplicationHelper do
  describe '#page_title' do
  end

  describe '#category_placement_anchor' do
    let(:category_placement) { FactoryGirl.build(:category_placement, id: 1, title: 'A title') }

    it 'should use the category placement title if available' do
      expect(helper.category_placement_anchor(category_placement)).to eq 'A_title_1'
    end

    it 'should use the category name if there is no title' do
      category_placement.title = nil
      expect(helper.category_placement_anchor(category_placement)).to eq 'Test_category_1'
    end
  end

  describe '#draw_stars' do
    describe 'should return html with correct on and off class values' do
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


end

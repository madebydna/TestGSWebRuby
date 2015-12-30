require 'spec_helper'

describe SchoolHelper do

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

end

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

  shared_examples_for 'produces a correct zillow campaign code' do
    {
        show: 'schoolsearch',
        city_browse: 'schoolsearch',
        district_browse: 'schoolsearch',
        search: 'schoolsearch',
        overview: 'localoverview',
        reviews: 'localreviews',
        quality: 'localquality',
        details: 'localdetails',
        unknown: 'gstrackingpagefail'
    }.each do |action, default_campaign|
      it "should use #{default_campaign} for #{action} action" do
        allow(helper).to receive(:action_name).and_return(action.to_s)
        expect(subject).to eq("#{expected_url}#{default_campaign}")
      end
    end

    describe 'with a campaign parameter' do
      let (:campaign) { 'spec' }
      subject { helper.zillow_url(school, campaign) }

      it 'should use provided campaign parameter regardless of action' do
        allow(helper).to receive(:action_name).and_return('show')
        expect(subject).to eq("#{expected_url}#{campaign}")
      end
    end
  end

  describe '#zillow_url' do
    subject { helper.zillow_url(school) }

    describe 'without a school' do
      it_behaves_like 'produces a correct zillow campaign code' do
        let (:school) { nil }
        let (:expected_url) { 'http://www.zillow.com/?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=' }
      end
    end

    describe 'with a school' do
      it_behaves_like 'produces a correct zillow campaign code' do
        let (:school) { double }
        let (:expected_url) { 'http://www.zillow.com/CA-94611?cbpartner=Great+Schools&utm_source=Great_Schools&utm_medium=referral&utm_campaign=' }

        before do
          allow(school).to receive(:zipcode).and_return('94611-1234')
          allow(school).to receive(:state).and_return('ca')
        end
      end
    end
  end
end

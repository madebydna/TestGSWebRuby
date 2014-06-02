require 'spec_helper'

describe 'shared/_search_hero.html.erb' do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }
  before(:each) do
    allow(view).to receive(:sponsor) { { text: "I'm a sponsor", path: '/image/path/woot' } }
    allow(view).to receive(:hero_image) { nil }
    allow(view).to receive(:hero_image_mobile) { nil }
    allow(view).to receive(:collection_nickname) { 'Fiji' }
    allow(view).to receive(:sponsor) { nil }
    allow(view).to receive(:params) { { state: 'michigan', city: 'detroit' } }
    allow(view).to receive(:browse_links) { nil }
  end

  context 'on a city page' do
    before(:each) do
      allow(view).to receive(:collection_id) { 1 }
      allow(view).to receive(:state) { { short: 'mi', long: 'michigan' } }
      allow(view).to receive(:breakdown_results) { { foo: nil, bar: nil } }
    end

    it 'adds the collection_id to a name search' do
      render
      expect(rendered).to have_selector('input#js-collectionId', visible: false)
    end

    context 'without sponsors' do
      it 'renders without a sponsor bar' do
        allow(view).to receive(:sponsor) { nil }
        expect { render }.to_not raise_error
        expect(rendered).to_not have_selector('.sponsor-bar')
      end
    end
  end

  context 'on a state page' do
    before(:each) do
      allow(view).to receive(:state) { { short: 'IN', long: 'indiana' } }
      allow(view).to receive(:state_page) { true }

      render
    end

    it 'does not add the collection_id to a name search' do
      expect(rendered).to_not have_selector('input#js-collectionId')
    end
  end
end

require 'spec_helper'

describe 'shared/_search_hero.html.erb' do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }
  before(:each) do
    view.stub(:sponsor) { { text: "I'm a sponsor", path: '/image/path/woot' } }
    view.stub(:hero_image) { nil }
    view.stub(:hero_image_mobile) { nil }
    view.stub(:collection_nickname) { 'Fiji' }
    view.stub(:sponsor) { nil }
    view.stub(:params) { { state: 'michigan', city: 'detroit' } }
  end

  context 'on a city page' do
    before(:each) do
      view.stub(:collection_id) { 1 }
      view.stub(:state) { { short: 'mi', long: 'michigan' } }
      view.stub(:breakdown_results) { { foo: nil, bar: nil } }
    end

    context 'without breakdown results' do
      it 'renders an error message' do
        render
        expect(rendered).to have_content('No data found for school breakdown')
      end
    end

    it 'adds the collection_id to a name search' do
      render
      expect(rendered).to have_selector('input#js-collectionId', visible: false)
    end

    context 'without sponsors' do
      it 'renders without a sponsor bar' do
        view.stub(:sponsor) { nil }
        expect { render }.to_not raise_error
        expect(rendered).to_not have_selector('.sponsor-bar')
      end
    end
  end

  context 'on a state page' do
    before(:each) do
      view.stub(:state) { { short: 'IN', long: 'indiana' } }
      view.stub(:state_page) { true }

      render
    end
    it 'does not render browse links' do
      expect(rendered).to_not have_selector('.browse-school-link')
    end

    it 'does not add the collection_id to a name search' do
      expect(rendered).to_not have_selector('input#js-collectionId')
    end
  end
end

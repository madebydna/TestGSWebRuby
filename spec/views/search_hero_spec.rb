require 'spec_helper'

describe 'shared/_search_hero.html.erb' do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }

  context 'on a city page' do
    before(:each) do
      view.stub(:collection_nickname) { 'detoit' }
      view.stub(:collection_id) { 1 }
      view.stub(:state) { { short: 'mi', long: 'michigan' } }
      view.stub(:breakdown_results) { { foo: nil, bar: nil } }
      view.stub(:hero_image) { nil }
      view.stub(:hero_image_mobile) { nil }
      render
    end

    context 'without breakdown results' do
      it 'renders an error message' do
        expect(rendered).to have_content('No data found for school breakdown')
      end
    end

    it 'adds the collection_id to a name search' do
      expect(rendered).to have_selector('input#js-collectionId', visible: false)
    end
  end

  context 'on a state page' do
    before(:each) do
      view.stub(:collection_nickname) { 'Indiana' }
      view.stub(:state) { { short: 'IN', long: 'indiana' } }
      view.stub(:hero_image) { nil }
      view.stub(:hero_image_mobile) { nil }
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

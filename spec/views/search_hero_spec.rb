require 'spec_helper'

describe 'shared/_search_hero.html.erb' do
  let(:city_page_url) { 'http://localhost:3000/michigan/detroit' }

  context 'without a sponsor' do
    it 'does not render sponsor information' do
      view.stub(:collection_nickname) { 'detoit' }
      view.stub(:collection_id) { 1 }
      view.stub(:state) { { short: 'mi', long: 'michigan' } }
      view.stub(:breakdown_results) { [] }
      view.stub(:sponsor) { nil }
      view.stub(:hero_image) { nil }
      view.stub(:hero_image_mobile) { nil }
      render

      expect(rendered).to_not have_selector 'a[href="education-community/partner"]'
    end
  end

  context 'on a city page' do
    context 'without breakdown results' do
      it 'renders an error message' do
        view.stub(:collection_nickname) { 'detoit' }
        view.stub(:collection_id) { 1 }
        view.stub(:state) { { short: 'mi', long: 'michigan' } }
        view.stub(:sponsor) { { text: 'foo bar baz', path: 'http://google.com' } }
        view.stub(:breakdown_results) { { foo: nil, bar: nil } }
        view.stub(:hero_image) { nil }
        view.stub(:hero_image_mobile) { nil }
        render

        expect(rendered).to have_content('No data found for school breakdown')
      end
    end
  end

  context 'on a state page' do
    it 'does not render browse links'
  end
end

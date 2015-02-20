require 'spec_helper'

describe 'search/_change_location' do
  describe 'selected state' do
    context 'when selected state has one word' do
      it 'capitalizes the word ' do
        render partial: "search/change_location.html.erb", locals: {choose_state: 'ca'}
        expect(rendered).to have_css('span.js-currentLocationText',text: 'California')
      end
    end
    context 'when selected state has more than one word' do
      it 'capitalizes both words' do
        render partial: "search/change_location.html.erb", locals: {choose_state: 'nh'}
        expect(rendered).to have_css('span.js-currentLocationText',text: 'New Hampshire')
      end
    end
    context 'when selected state is Washington DC' do
      it 'capitalizes both Washington and DC' do
        render partial: "search/change_location.html.erb", locals: {choose_state: 'dc'}
        expect(rendered).to have_selector('span.js-currentLocationText',text: 'Washington DC')
      end
    end
  end
end
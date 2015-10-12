require 'spec_helper'
require 'features/examples/page_examples'

describe 'search/_change_location', js: true do
  DESKTOP_SELECTPICKER = "[data-id='change-location-desktop']"
  MOBILE_SELECTPICKER = "[data-id='change-location-mobile']"
  describe 'selected state' do
    context 'when selected state has one word' do
      before do
        render partial: "search/change_location.html.erb", locals: {choose_state: 'ca'}
      end
      include_example 'should have selectpicker with selected value', DESKTOP_SELECTPICKER, 'California'
    end
    context 'when selected state has more than one word' do
      it 'capitalizes both words' do
        render partial: "search/change_location.html.erb", locals: {choose_state: 'nh'}
        expect(rendered).to have_css('span.filter-option',text: 'New Hampshire')
      end
    end
    context 'when selected state is Washington DC' do
      it 'capitalizes both Washington and DC' do
        render partial: "search/change_location.html.erb", locals: {choose_state: 'dc'}
        expect(rendered).to have_selector('span.filter-option',text: 'Washington DC')
      end
    end
    context 'when no state is selected' do
      it 'shows Nationwide' do
        render partial: "search/change_location.html.erb", locals: {choose_state: nil}
        expect(rendered).to have_selector('span.filter-option',text: 'Nationwide')
      end
    end
  end
end

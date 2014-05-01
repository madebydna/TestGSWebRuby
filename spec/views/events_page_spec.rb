require 'spec_helper'

describe 'cities/events.html.erb' do
  before(:each) do
    view.stub(:logged_in?) { false }
    assign(:state, { long: 'Michigan', short: 'MI' })
    view.stub(:city_params).and_return({ state: 'michigan', city: 'detroit' })
    assign(:hub_params, { state: 'michigan', city: 'detroit' })
  end
  context 'by default' do
    before(:each) do
      clean_dbs :gs_schooldb
      FactoryGirl.create(:important_events_collection_config)
      assign(:events, CollectionConfig.important_events(1))
    end
    after { clean_dbs :gs_schooldb }

    it 'renders an event list' do
      render
      expect(rendered).to render_template('cities/_events_list')
    end
  end

  context 'with malformed or missing data' do
    it 'does not render an event list' do
      render
      expect(rendered).to_not render_template('cities/_events_list')
    end
  end
end

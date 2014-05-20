require 'spec_helper'

describe 'cities/_upcoming_events.html.erb' do
  context 'without events' do
    it 'hides the section' do
      allow(view).to receive(:important_events) { nil }
      allow(view).to receive(:params) { { city: 'detroit', state: 'michigan' } }
      render
      expect(rendered).to_not have_selector('.row')
    end
  end

  context 'by default' do
    before(:each) do
      FactoryGirl.create(:important_events_collection_config)
      allow(view).to receive(:params) { { city: 'detroit', state: 'michigan' } }
      allow(view).to receive(:important_events) { important_events }
    end
    after(:each) { clean_dbs :gs_schooldb }
    let(:configs) { CollectionConfig.all }
    let(:important_events) { CollectionConfig.city_hub_important_events(configs) }

    it 'shows 2 upcoming events' do
      render
      expect(rendered).to have_selector('.upcoming-event', count: 2)
    end

    it 'renders an hr tag' do
      render
      expect(rendered).to have_selector('hr')
    end
  end

  context 'on a community page' do
    before(:each) do
      FactoryGirl.create(:important_events_collection_config)
      allow(view).to receive(:params) { { city: 'detroit', state: 'michigan' } }
      allow(view).to receive(:important_events) { important_events }
    end
    after(:each) { clean_dbs :gs_schooldb }
    let(:configs) { CollectionConfig.all }
    let(:important_events) { CollectionConfig.city_hub_important_events(configs) }

    it 'does not render an hr tag' do
      allow(view).to receive(:community_page) { true }
      render
      expect(rendered).to_not have_selector('hr')
    end
  end
end

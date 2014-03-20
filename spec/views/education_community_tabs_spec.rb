require 'spec_helper'

describe 'cities/_tabs.html.erb' do
  before(:each) do
    view.stub(:city) { 'detroit' }
    view.stub(:state) { 'michigan' }
  end

  it 'sets an active class' do
    view.stub(:show_tabs)  { true }
    view.stub(:tab) { 'Education' }
    render

    expect(rendered).to have_css('li.active', text: 'Education')
  end

  context 'with show_tabs set to false' do
    it 'hides tabs' do
      view.stub(:show_tabs)  { false }
      view.stub(:tab) { 'Funders' }
      render

      expect(rendered).to_not have_css('ul.education-community-tabs')
    end
  end


end

describe 'cities/_education_community_partners.html.erb' do
  before(:each) do
    collection_configs = [FactoryGirl.build(:community_partners_collection_config)]
    @partners = CollectionConfig.ed_community_partners(collection_configs)
  end

  context 'by default' do
    it 'renders partners' do
      view.stub(:show_tabs)  { true }
      @tab = 'Funders'
      render

      expect(rendered).to have_css('.community-partner-row')
    end
  end

  context 'with show_tabs set to false' do
    it 'renders all the partners' do
      view.stub(:show_tabs)  { false }
      render

      expect(rendered).to have_css('.community-partner-row')
    end
  end

  context 'with malformed or missing partner data' do
    it 'renders an error message' do
      @partners = nil
      view.stub(:show_tabs) { true }
      view.stub(:tab) { 'Funders' }
      render

      expect(rendered).to have_text("No Data Found - Key eduCommPage_partnerData")
    end
  end
end


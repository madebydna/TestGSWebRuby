require 'spec_helper'

describe 'shared/_tabs.html.erb' do
  before(:each) do
    allow(view).to receive(:city) { 'detroit' }
    allow(view).to receive(:logged_in?) { false }
    allow(view).to receive(:state) { 'michigan' }
    allow(view).to receive(:gs_legacy_url_encode) { |input| input }
  end

  it 'sets an active class' do
    allow(view).to receive(:show_tabs)  { true }
    allow(view).to receive(:tab) { 'Education' }
    render

    expect(rendered).to have_css('li.active', text: 'Education')
  end

  context 'with show_tabs set to false' do
    it 'hides tabs' do
      allow(view).to receive(:show_tabs)  { false }
      allow(view).to receive(:tab) { 'Funders' }
      render

      expect(rendered).to_not have_css('ul.nav-pills')
    end
  end


end

describe 'shared/_education_community_partners.html.erb' do
  before(:each) do
    collection_configs = [FactoryGirl.build(:community_partners_collection_config)]
    @partners = CollectionConfig.ed_community_partners(collection_configs)
  end

  context 'by default' do
    it 'renders partners' do
       pending("something else getting finished")
      allow(view).to receive(:show_tabs)  { true }
      @tab = 'Funders'
      render

      expect(rendered).to have_css('.community-partner-row')
    end
  end

  context 'with show_tabs set to false' do
    it 'renders all the partners' do
       pending("something else getting finished")
      allow(view).to receive(:show_tabs)  { false }
      render

      expect(rendered).to have_css('.community-partner-row')
    end
  end

  context 'with malformed or missing partner data' do
    it 'renders an error message' do
       pending("something else getting finished")
      @partners = nil
      allow(view).to receive(:show_tabs) { true }
      allow(view).to receive(:tab) { 'Funders' }
      render

      expect(rendered).to have_text("No Data Found - Key eduCommPage_partnerData")
    end
  end
end

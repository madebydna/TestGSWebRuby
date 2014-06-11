require 'spec_helper'

# Sins.
# def city_hub_stubs(view)
#   view.stub(:collection_id) { 1 }
#   allow(view).to receive(:city) { 'detroit' }
#   allow(view).to receive(:logged_in?) { false } #sins(?)
#   allow(view).to receive(:state) { 'michigan' }
# end

# def state_hub_stubs(view)
#   view.stub(:collection_id) { 6 }
#   allow(view).to receive(:logged_in?) { false } #sins(?)
#   allow(view).to receive(:state) { 'indiana' }
# end

# describe 'shared/community.html.erb' do
#   context 'showing tabs on a state page' do
#     before do
#       state_hub_stubs(view)
#     end

#     it 'sets a base href to the state page' do
#       render
#       debugger
#       puts 'foo'
#       # find selector, make sure state is in the href
#     end
#   end

#   context 'showing tabs on a city page' do
#     before do

#     end

#     it 'sets a base href to the city page' do
#       render
#       expect(rendered).to have_selector('base')
#       # Find the selector, make sure the city is in the href
#     end
#   end
# end

describe 'shared/_tabs.html.erb' do
  before(:each) do
    city_hub_stubs(view)
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

      expect(rendered).to_not have_css('ul.education-community-tabs')
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
      allow(view).to receive(:show_tabs)  { true }
      @tab = 'Funders'
      render

      expect(rendered).to have_css('.community-partner-row')
    end
  end

  context 'with show_tabs set to false' do
    it 'renders all the partners' do
      allow(view).to receive(:show_tabs)  { false }
      render

      expect(rendered).to have_css('.community-partner-row')
    end
  end

  context 'with malformed or missing partner data' do
    it 'renders an error message' do
      @partners = nil
      allow(view).to receive(:show_tabs) { true }
      allow(view).to receive(:tab) { 'Funders' }
      render

      expect(rendered).to have_text("No Data Found - Key eduCommPage_partnerData")
    end
  end
end


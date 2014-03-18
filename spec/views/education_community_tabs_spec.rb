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

    it 'renders all the partners'
  end


end

describe 'cities/_education_community_partners.html.erb' do
  context 'with malformed or missing partner data' do
    it 'rrenders an error message' do
      view.stub(:show_tabs) { true }
      view.stub(:tab) { 'Funders' }
      render

      expect(rendered).to have_text("No Data Found - Key eduCommPage_partnerData")
    end
  end
end


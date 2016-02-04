require "spec_helper"

describe "views/search/search_result/_container.html.erb" do
  let(:school) do
    s = FactoryGirl.build(:school_search_result, street: '1234 Main St', zipcode: '94612', id: 25, city: 'Chicago', name: 'Chicago Unified High School', state_name: 'Delaware', state: 'De', overall_gs_rating: '12' )

    #require 'pry'; binding.pry
  end

  let(:decorated_school) do
    ds = Struct.new(:state, :name, :id, :process_level)
    ds.new( 'State: CA', 'Name: Urban Montessori School', 'Id: 10', 'Process Level: 4-8')
  end

  let(:school_page_url) do 'http://www.umcs.com' end


  before do
    view.extend(UrlHelper)
    render :partial => "search/search_result/container", locals: { school: school, decorated_school: decorated_school, school_page_url: school_page_url }
  end

  it "displays search result title" do
    #allow(:school).to receive(:overall_gs_rating).and_return('12')
   expect(response).to render_template( partial: 'search/search_result/_title' )
   expect(rendered).to have_content('Chicago Unified High School')
  end

  it "displays search result icons container" do
    expect(response).to render_template(partial: 'search/search_result/_icons_container')
  end

  it "displays search result buttons container" do
    expect(response).to render_template(partial: 'search/search_result/_buttons_container')
  end

end
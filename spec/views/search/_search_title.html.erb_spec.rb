require "spec_helper"
#require "views/search/search_results"

describe "views/search/filters/_title.html.erb" do

  let(:school) { FactoryGirl.build(:school_search_result ) }
  let(:decorated_school) do
    ds = Struct.new(:grade_range, :process_level, :distance)
    ds.new( '2-8', '2-8', '10')
  end
  let(:school_page_url) { 'http://www.google.com' }

  before do
    view.extend(UrlHelper)
    render :partial => "views/search/filters/_title.html.erb"
  end


  it "displays the school title" do
    #require 'pry'; binding.pry;



    rendered.should have_css('.rs-schoolName')

  end
end
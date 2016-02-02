require "spec_helper"
#require "views/search/search_results"

describe "views/search/search_result/_title.html.erb" do

  let(:school) { FactoryGirl.build(:demo_school, street: '1234 Main St', zipcode: '94612' ) }
  let(:decorated_school) do
    ds = Struct.new(:grade_range, :process_level, :distance)
    ds.new( 'Grade-Range: 2-8', 'Process-Level: 4-12', 'Distance: 10')
  end
  let(:school_page_url) { 'http://www.google.com' }
  let(:by_location) { false }

  before do
    view.extend(UrlHelper)
    allow(view).to receive(:search_by_location?).and_return by_location
    render :partial => "search/search_result/title", locals: {school: school, decorated_school: decorated_school, school_page_url: school_page_url}
  end

  context "when searching by location" do
    let(:by_location) { true }
    it "displays the distance" do
      expect(rendered).to have_content('Distance: 10 miles')
    end
  end

  context "with decorated_school grade_range" do
    it "displays grade range" do
      expect(rendered).to have_content('Grade-Range: 2-8')
    end
  end

  context "with decorated_school process_level" do
    let(:decorated_school) do
      ds = Struct.new(:grade_range, :process_level, :distance)
      ds.new( false, 'Process-Level: 4-12', 'Distance: 10')
    end

    it "displays process level" do
      expect(rendered).to have_content('Process-Level: 4-12')
    end
  end

  it "displays the school title" do
    expect(rendered).to have_content('A demo school')
  end
end
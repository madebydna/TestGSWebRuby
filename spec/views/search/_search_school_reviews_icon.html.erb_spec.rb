require "spec_helper"

describe "views/search/search_result/_school_reviews_icon.html.erb" do
  let(:school) do
    s = FactoryGirl.build(:school_search_result, community_rating: 77, review_count: 62 )
  end

  let(:school_reviews_page_url) do 'http://www.umcs.com/school_reviews' end

  before do
    view.extend(UrlHelper)
    render :partial => "search/search_result/school_reviews_icon", locals: { school: school, school_reviews_page_url: school_reviews_page_url }
  end

  it "displays review count" do
    expect(rendered).to have_content('62 reviews')
  end

end
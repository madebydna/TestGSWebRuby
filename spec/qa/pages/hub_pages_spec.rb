

describe '#hub pages', remote:true, safe_for_prod: true  do
  before {stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {})}
  {
    '/delaware' => 'Delaware',
    '/georgia' => 'Georgia',
    '/oklahoma' => 'Oklahoma',
    '/north-carolina' => 'North Carolina',
  }.each do |uri, hub_title|
    describe "#{uri} hub page" do
      before { visit uri }
      it "shows title of #{hub_title}" do
        expect(page).to have_css(:title, visible: false, text: hub_title)
      end
      xit "has h1 of #{hub_title}" do
        expect(page).to have_css(:h1, visible: true, text: hub_title)
      end
    end
  end
end

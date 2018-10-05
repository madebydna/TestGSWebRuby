

describe '#hub pages', remote:true, safe_for_prod: true  do
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
      it "has h1 of #{hub_title}" do
        expect(page).to have_css(:h1, visible: true, text: hub_title)
      end
    end
  end
end

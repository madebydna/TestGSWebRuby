require 'remote_spec_helper'

describe '#hub pages', remote:true, safe_for_prod: true  do
  {
    '/delaware' => 'Delaware',
    '/georgia' => 'Georgia',
    '/oklahoma' => 'Oklahoma',
    '/north-carolina' => 'North Carolina',
    '/michigan/detroit' => 'Detroit',
    '/wisconsin/milwaukee' => 'Milwaukee',
    '/washington-dc/washington' => 'Washington, DC',
    '/indiana/indianapolis' => 'Indianapolis',
    '/oklahoma/tulsa' => 'Tulsa',
    '/colorado' => 'Colorado'
  }.each do |uri, hub_title|
    describe "#{uri} hub page" do
      before { visit uri }
      it "shows title of #{hub_title}" do
        pending 'See JT-3159' if uri == '/washington-dc/washington'
        expect(page).to have_css(:title, visible: false, text: hub_title)
      end
      it "has h1 of #{hub_title}" do
        expect(page).to have_css(:h1, visible: true, text: hub_title)
      end
    end
  end
end

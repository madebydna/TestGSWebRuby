shared_example 'should highlight column' do |number|
  expect(community_spotlight_page.desktop_scorecard.table[:class]).to include("highlight#{number}")
end

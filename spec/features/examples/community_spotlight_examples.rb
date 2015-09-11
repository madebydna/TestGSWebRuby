shared_example 'should highlight column' do |number|
  expect(community_spotlight_page.desktop_scorecard.table[:class]).to include("highlight#{number}")
end

shared_example 'should have dropdown with selected value' do |dropdown_selector, value|
  expect(community_spotlight_page.find(dropdown_selector)[:title]).to eq(value)
end

# require 'remote_spec_helper'
# require 'features/page_objects/search_page'
#
# describe 'User sees assigned schools', js:true, type: :feature, remote: true do
#   before do
#     visit '/search/search.page?lat=37.8077447&lon=-122.2653488&zipCode=94612&state=CA&locationType=premise&normalizedAddress=Lake%20Merritt%20Plaza%2C%201999%20Harrison%20St%2C%20Oakland%2C%20CA%2094612&city=Oakland&sortBy=DISTANCE&locationSearchString=1999%20harrison%20st%2C%20oakland%2C%20ca&distance=5'
#     wait_for_ajax
#   end
#   subject(:page_object) { SearchPage.new }
#   it { is_expected.to have_assigned_schools }
#   its('assigned_schools.first') { is_expected.to have_gs_rating }
#   its('assigned_schools.first.gs_rating') { is_expected.to have_content(9) }
# end
#
# describe 'User doesnt see NR rating for assigned school', js: true, type: :feature, remote: true do
#   before do
#     visit '/search/search.page?lat=59.6525553&lon=-151.5058851&zipCode=99603&state=AK&locationType=street_address&normalizedAddress=1340%20East%20End%20Rd%2C%20Homer%2C%20AK%2099603&city=Homer&sortBy=DISTANCE&locationSearchString=1340%20east%20end%20rd%2C%2099603&distance=5'
#     wait_for_ajax
#   end
#   subject(:page_object) { SearchPage.new }
#   it { is_expected.to have_assigned_schools }
#   its('assigned_schools.first') { is_expected.to_not have_gs_rating }
# end

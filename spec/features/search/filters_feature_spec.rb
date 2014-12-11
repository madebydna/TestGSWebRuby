require 'spec_helper'
require_relative 'search_spec_helper'

#### This spec is commented out because I could not get javascript to run on the page.
#### Getting this error: Capybara::NotSupportedByDriverError, which supposedly we should not get
#### when using the webkit driver.

# def checkbox_xpath(name, value)
#   "//label[@data-gs-checkbox-name='#{name}'][@data-gs-checkbox-value='#{value}']/span"
# end
#
# feature 'Test filters javascript' do
#   include SearchSpecHelper
#
#   context 'with no filters selected' do
#
#     context 'clicking a hard filter' do
#
#       let(:checkbox_xpath) { checkbox_xpath('st[]', 'public') }
#
#       subject do
#         set_up_city_browse('de','dover')
#         checkbox = page.all(:xpath, checkbox_xpath).last
#         checkbox.click
#         find(:css, '.js-submitSearchFiltersForm').click
#         page
#       end
#
#       it 'should still be clicked after page load' do
#         # find(:css, '.js-searchFiltersDropdown').click
#         checkbox = subject.all(:xpath, checkbox_xpath).last
#         expect(checkbox).to have_css('.i-16-blue-check-box')
#       end
#
#       it 'should alter the url' do
#         subject
#         expect(current_url).to include('st[]=public')
#       end
#     end
#
#     context 'clicking a soft filter' do
#     end
#   end
#   context 'with filters selected' do
#   end
# end

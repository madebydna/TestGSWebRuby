require 'remote_spec_helper'
require 'features/page_objects/school_profiles_page'

describe 'school name shows up on a preschool profile', js: true, type: :feature, remote: true do
  before { visit '/new-jersey/newark/preschools/Broadway-Mini-Mall-Head-Start/7453/' }
  subject(:page_object) { SchoolProfilesPage.new }
  its(:h1) { is_expected.to have_text('Broadway Mini Mall Head Start') }
end


# frozen_string_literal: true

require 'features/page_objects/compare_page'

xdescribe 'Search page' do
  let(:uri) { '' }
  before { visit uri }
  subject { ComparePage.new }

  sample_uris_to_pinned_schools = [
    ['/compare?breakdown=Hispanic&gradeLevels%5B%5D=h&lat=34.073872&lon=-118.203857&schoolId=2198&sort=testscores&state=CA', 'Abraham Lincoln Senior High School'],
    ['/compare?breakdown=Asian+or+Pacific+Islander&gradeLevels%5B%5D=h&lat=40.77013&lon=-73.953262&schoolId=6854&sort=testscores&state=NY', 'Eleanor Roosevelt High School']
  ]

  sample_uris_to_pinned_schools.each do |(uri, school_name)|
    describe "#{uri} should show #{school_name} on top" do
      let(:uri) { uri }
      it { is_expected.to have_school_table }
      its('school_table.pinned_school') { is_expected.to have_text(school_name) }
      its('school_table.first_non_pinned_school') { is_expected.to be_present }
    end
  end

  describe 'sorts by name' do
    let(:uri) { '/compare?breakdown=Asian+or+Pacific+Islander&gradeLevels%5B%5D=h&lat=40.77013&lon=-73.953262&schoolId=6854&sort=testscores&state=NY&sort=name' }
    its('school_table.first_non_pinned_school.text') { is_expected.to include('A Philip Randolph Campus High School') }
  end
end
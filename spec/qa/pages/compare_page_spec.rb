require 'features/page_objects/compare_page'

describe 'Compare page', remote: true do

  subject { ComparePage.new }

  sample_uris_to_pinned_schools = [
    [{ breakdown: 'Hispanic', "gradeLevels[]": "h", id: 2198, lat: 34.073872, lon: -118.203857, sort: "testscores", state: "CA" }, 'Abraham Lincoln Senior High School'],
    [{ breakdown: 'Asian or Pacific Islander', "gradeLevels[]": "h", id: 6854, lat: 40.77013, lon: -73.953262, sort: "testscores", state: "NY" }, 'Eleanor Roosevelt High School']
  ]

  sample_uris_to_pinned_schools.each_with_index do |(query, school_name), i|
    describe "compare #{query[:state]} school and breakdown #{query[:breakdown]} should show pinned school on top" do
      before do
        subject.load(query: query)
      end

      it { is_expected.to have_school_table }
      its('school_table.pinned_school') { is_expected.to have_text(school_name) }
      its('school_table.first_non_pinned_school') { is_expected.to be_present }

      it 'has schools sorted by Test Score'
    end
  end

  describe 'sorts by name' do
    before do
      subject.load(query: { breakdown: "African American", "gradeLevels[]": "e", id: 27, lat: 37.892673, lon: -122.26355, sort: "name", state: "CA" })
    end

    it 'should have alphabetically first school as the first non-pinned school' do
      expect(subject.school_table.first_non_pinned_school.text).to include('Anna Yates Elementary School')
    end
  end

  describe 'sorts by distance' do
    # expectations of changing sort order to distance and checking first 3 schools
  end

  describe 'changing the breakdown' do
    before do 
      subject.load(query: {:breakdown=>"Hispanic", :"gradeLevels[]"=>"h", :id=>"2198", :lat=>"34.073872", :lon=>"-118.203857", :sort=>"distance", :state=>"CA"})
    end
    
    it 'shows a new list based on the other breakdown' do
      # change breakdown to Asian
    end
  end

  describe 'changing the radius' do
    before do 
      subject.load(query: {:breakdown=>"Hispanic", :"gradeLevels[]"=>"h", :id=>"2198", :lat=>"34.073872", :lon=>"-118.203857", :sort=>"distance", :state=>"CA"})
    end

    it 'should increase the list of compared schools' # Change distance filter to 10 miles
  end

  context 'densely populated areas' do
    before do
      subject.load(query: {:breakdown=>"African American", :"gradeLevels[]"=>"p", :id=>"96", :lat=>"38.879833", :lon=>"-77.018288", :sort=>"testscores", :state=>"DC"})
    end

    it 'should display all schools inside the radius' # Change distance filter to 60 miles
    # Note: in practice, this only displays about 85 schools, the furthest one being 7.29 miles away
  end


end
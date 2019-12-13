require 'features/page_objects/district_boundaries_page'

describe 'District boundaries page', remote: true do
  subject { DistrictBoundariesPage.new }
  before do 
    subject.load(query: { districtId: 888, level: "h", schoolId: 5980, state: 'TX'})
  end

  it { is_expected.to be_displayed }

  it 'should have correct district selected' # ensure San Antonio Independent School District is selected

  it 'should filter by school level' # ensure only high schools are shown

  it 'should not list charter or private schools'

  it 'should display list of public schools by descending GS rating'


  describe 'changing the school district' do
    
  end

  describe 'changing the school level filter' do
    
  end

  describe 'adding or removing charter schools' do
    
  end

  describe 'adding or removing private schools' do
    
  end

  describe 'Address Search' do
    describe 'by zip code' do
      # e.g. 94805
    end

    describe 'by street and city' do
      # e.g. 2001 Broadway, Oakland
    end

    describe 'by city and state' do
      # e.g. Berkeley, CA
    end


    describe 'by city and state' do
      # e.g. Berkeley, CA
    end
  end


end
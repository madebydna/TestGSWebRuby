require 'features/page_objects/district_home_page'

describe 'District page', remote: true do
  subject { DistrictHomePage.new }
  describe 'TOC' do
    before do
      subject.load(state: 'florida', city: 'west-palm-beach', district: 'palm-beach')
    end

    it { is_expected.to be_displayed(state: 'florida', city: 'west-palm-beach', district: 'palm-beach') }

    it 'should have expected sections'
  end
  
  describe 'Schools by type' do
    it 'should have linked list item for Preschools'
    it 'should have linked list item for Elementary schools'
    it 'should have linked list item for Middle schools'
    it 'should have linked list item for High schools'
    it 'should have linked list item for All schools'
  end

  describe 'Best schools' do
    it 'should display top 5 elementary schools by default'
    it 'should allow to toggle display to middle schools'
    it 'should allow to toggle display to high schools'
    it 'should link to more schools of type'
  end

  describe 'Academics' do
    it 'should display test scores by breakdown'
  end
  
  describe 'Student demographics' do
    it 'should display pie charts with demographic breakdowns'
  end

  describe 'District calendar' do
    it 'should display upcoming holidays'
  end

  describe 'Community resources' do
    it 'should display school board lookup'
  end

  describe 'Nearby homes' do
    it 'should display homes for sale near West Palm Beach'
  end

  describe 'Reviews' do
    it 'should display 3 most recent reviews'
  end

  context 'CSA State' do
    it 'should have College success award winners in top schools module'
  end

end
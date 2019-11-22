require 'features/page_objects/city_home_page'

describe 'City page', remote: true do
  subject { CityHomePage.new }
  describe 'TOC' do
    before do
      subject.load(state: 'colorado', city: 'denver')
    end

    it { is_expected.to be_displayed(state: 'colorado', city: 'denver') }

    it 'should have expected sections'
  end
  
  describe 'Schools by type' do
    it 'should have linked list item for Preschools'
    it 'should have linked list item for Elementary schools'
    it 'should have linked list item for Middle schools'
    it 'should have linked list item for High schools'
    it 'should have linked list item for Public district schools'
    it 'should have linked list item for Public charter schools'
    it 'should have linked list item for Private schools'
    it 'should have linked list item for All schools'
  end

  describe 'Best schools' do
    it 'should display top 5 elementary schools by default'
    it 'should allow to toggle display to middle schools'
    it 'should allow to toggle display to high schools'
    it 'should link to more schools of type'
  end
  
  describe 'Districts' do
    it 'should display largest school districts in descending order'
  end

  describe 'Community resources' do
    it 'should display transportation options'
  end

  describe 'Nearby homes' do
    it 'should display homes for sale in Denver'
  end

  describe 'Reviews' do
    it 'should display 3 most recent reviews'
  end

  describe 'Neighboring Cities' do
    it 'should display at most eight neighboring cities'
  end

  context 'CSA State' do
    it 'should have College success award winners in top schools module'
  end

end
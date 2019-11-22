require 'features/page_objects/state_home_page'

describe 'State page', remote: true do
  subject { StateHomePage.new }
  describe 'TOC' do
    before do
      subject.load(state: 'arizona')
    end

    it { is_expected.to be_displayed(state: 'arizona') }

    it 'should have expected sections'
  end

  describe 'Best schools' do
    it 'should display top 5 elementary schools by default'
    it 'should allow to toggle display to middle schools'
    it 'should allow to toggle display to high schools'
    it 'should link to more schools of type'
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

  describe 'Academics' do
    
  end

  describe 'Student demographics' do
    
  end

  describe 'Cities' do
    
  end

  describe 'Districts' do
    it 'should display largest school districts in descending order'
  end

  describe 'Reviews' do
    
  end

  context 'CSA State' do
    it 'should have Award Winning Schools in TOC'
    it 'should have Award-winning high schools section'
  end

  context 'Non-CSA state' do
    it 'should not have Award Winning Schools in TOC'
    it 'should not have Award-winning high schools section'
  end
end
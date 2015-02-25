require 'spec_helper'

feature 'Nearby schools' do
  let!(:school) { FactoryGirl.create(:school) }
  let!(:overview) { FactoryGirl.create(:page, name: 'Overview') }
  after(:each) do
    NearbySchool.delete_all
    clean_models :ca, School
    clean_models  User, HubCityMapping, CensusDataType
  end
  subject do
    visit school_path(school)
    page
  end

  context 'When there are four nearby schools' do
    let!(:neighboring_schools) do
      [
        FactoryGirl.create(:school, name: 'school a'),
        FactoryGirl.create(:school, name: 'school b'),
        FactoryGirl.create(:school, name: 'school c'),
        FactoryGirl.create(:school, name: 'school d'),
      ]
    end
    let!(:nearby_school_objects) do
      neighboring_schools.map do |neighbor|
        FactoryGirl.create(
          :nearby_school,
          school: school,
          neighbor: neighbor,
          distance: rand(10)
        )
      end
    end

    # scenario 'User sees four nearby schools' do
    #   neighboring_schools[0..3].each do |s|
    #     expect(subject).to have_content(s.name)
    #   end
    # end

    # scenario 'User sees nearby school section' do
    #   expect(subject).to have_content('Nearby schools')
    # end
  end

  context 'When there are fewer than four nearby schools' do
    let!(:neighboring_schools) do
      [
        FactoryGirl.create(:school, name: 'school a'),
        FactoryGirl.create(:school, name: 'school b'),
        FactoryGirl.create(:school, name: 'school c'),
      ]
    end
    let!(:nearby_school_objects) do
      neighboring_schools.map do |neighbor|
        FactoryGirl.create(
          :nearby_school,
          school: school,
          neighbor: neighbor,
          distance: rand(10)
        )
      end
    end

    scenario 'User does not see the three nearby schools' do
      neighboring_schools[0..3].each do |s|
        expect(subject).to_not have_content(s.name)
      end
    end

    scenario 'User does not see nearby schools section' do
      expect(subject).to_not have_content('Nearby schools')
    end
  end
end

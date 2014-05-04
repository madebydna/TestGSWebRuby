require 'spec_helper'

feature 'School moderation' do
  let(:school) { FactoryGirl.create(:school, state: 'ca', name: 'ABC School') }

  after(:each) do
    clean_dbs :ca, :surveys
  end

  scenario 'moderator loads the page' do
    visit admin_school_moderate_path(
      state: 'california',
      school_id: school.id
    )
    expect(page).to have_content 'ABC School'
  end

  feature 'displays the school\'s reviews' do
    let!(:review) do
      FactoryGirl.create(
        :school_rating,
        state: 'CA',
        school_id: school.id,
        posted: '2000-01-01'
      )
    end

    scenario 'the user sees the review posted date' do
      visit admin_school_moderate_path(
        state: 'california',
        school_id: school.id
      )
      expect(page).to have_content 'January 01, 2000'
    end
  end
end

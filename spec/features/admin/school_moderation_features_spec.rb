require 'spec_helper'

feature 'School moderation' do
  let!(:school) { FactoryGirl.create(:school, state: 'CA', name: 'ABC School') }
  let(:flagged_review) do
    FactoryGirl.create(
      :school_rating,
      :flagged,
      state: school.state,
      school_id: school.id,
      comments: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. \
      Dolores, officiis excepturi nostrum sit totam dignissimos laborum \
      ipsam maxime! Vel, quo quisquam cum adipisci quod non facilis \
      consequatur! Dignissimos, illum, reiciendis.'
    )
  end
  let!(:reviews) do
    [
      FactoryGirl.create(
        :school_rating,
        state: school.state,
        school_id: school.id,
        comments: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. \
        Temporibus, distinctio, dicta, totam dolor aut officiis \
        necessitatibus odio ad iusto consequatur consequuntur nihil facilis \
        minima minus quia soluta harum perspiciatis saepe?'
      ),
      flagged_review
    ]
  end

  after(:each) do
    clean_dbs :ca
    clean_models SchoolRating, ReportedEntity
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
        state: school.state,
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

    scenario 'the moderator sees the school reviews' do
      visit admin_school_moderate_path(
        state: 'california',
        school_id: school.id
      )
      reviews.each { |r| expect(page).to have_content r.comments }
    end

    feature 'Resolving a flagged review' do
      subject do
        visit admin_school_moderate_path(
          state: 'california',
          school_id: school.id
        )
      end

      scenario 'Moderator sees the "Resolve flags" button' do
        subject
        expect(page).to have_selector(:link_or_button, 'Resolve flags')
      end

      feature 'When clicking the "Resolve flags" button' do
        before(:each) do
          subject
          page.click_button "js-resolve-review-#{flagged_review.id}"
        end

        scenario 'The review is no longer flagged' do
          reported_entities = ReportedEntity.find_by_reviews flagged_review
          expect(reported_entities.select(&:active?)).to be_empty
          
        end
      end
    end
  end
end

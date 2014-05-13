require 'spec_helper'

feature 'school profile snapshot module' do
  let(:snapshot) do
    FactoryGirl.create(
      :category,
      name: 'Snapshot',
      source: 'snapshot',
      page: 'Overview',
      layout: 'snapshot'
    )
  end

  let(:summer_program_data_point) do
    FactoryGirl.create(
      :category_data,
      category: snapshot,
      response_key: 'summer_program'
    )
  end

  let(:summer_program_esp_response) do
    FactoryGirl.create(
      :esp_response,
      response_key: 'summer_program',
      response_value: 'yes',
      school: school
    )
  end

  # before each example runs, create the objects defined above.
  # They might be "overridden" each of the different examples
  before(:each) do
    snapshot
    summer_program_data_point
    summer_program_esp_response
  end

  after(:each) do
    clean_models :ca, School, EspResponse
    clean_models User, Page, Category, CategoryData, CategoryPlacement
  end

  subject do
    visit school_path(school)
    page
  end

  context 'With any snapshot that shows summer programs' do
    let(:school) { FactoryGirl.create(:bay_farm_elementary_school) }

    scenario 'Snapshot label is displayed and capitalized' do
      expect(subject).to have_content('Summer_program')
    end

    feature 'The snapshot data point can be labeled' do
      # Change the definition of "summer_program_data_point" here
      # It will get created during the before(:each) step
      let(:summer_program_data_point) do
        FactoryGirl.create(
          :category_data,
          category: snapshot,
          response_key: 'summer_program',
          label: 'Summer program'
        )
      end
      scenario 'Summer program displays the custom label' do
        expect(subject).to have_content('Summer program')
      end
    end

    context 'When there is esp data for summer program' do
      let(:summer_program_esp_response) do
        FactoryGirl.create(
          :esp_response,
          response_key: 'summer_program',
          response_value: 'yes',
          school: school
        )
      end

      scenario 'Value is displayed and capitalized' do
        expect(subject).to have_content('Summer_program Yes')
      end
    end

    context 'When there\'s not esp data for summer program' do
      let(:summer_program_esp_response) { }

      scenario 'Summer program displays value of "no info"' do
        expect(subject).to have_content('Summer_program no info')
      end
    end
  end

  context 'When on Alameda High School' do
    let(:school) { FactoryGirl.create(:alameda_high_school) }

    scenario 'Summer program should not appear' do
      expect(subject).to_not have_content('Summer_program')
    end
  end

  context 'When on Emery Secondary School' do
    let(:school) { FactoryGirl.create(:emery_secondary) }

    scenario 'Summer program should appear' do
      expect(subject).to have_content('Summer_program')
    end
  end

  context 'When on Bay Farm Elementary School' do
    let(:school) { FactoryGirl.create(:bay_farm_elementary_school) }

    scenario 'Summer program should appear' do
      expect(subject).to have_content('Summer_program')
    end
  end
  
end
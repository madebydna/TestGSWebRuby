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
      response_key: 'summer_program',
      label: 'summer_program'
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

  let(:school_metadata) do FactoryGirl.create(:school_metadata, school_id: school.id, meta_key: 'collection_id', meta_value: 5)
  end

  # before each example runs, create the objects defined above.
  # They might be "overridden" each of the different examples
  before(:each) do
    snapshot
    summer_program_data_point
    summer_program_esp_response
    school_metadata
  end

  after(:each) do
    clean_models :ca, School, EspResponse, SchoolMetadata
    clean_models User, Page, Category, CategoryData, CategoryPlacement,HubCityMapping
  end

  subject do
    visit school_path(school)
    page
  end

  context 'With any snapshot that shows summer programs' do
    let(:school) { FactoryGirl.create(:an_elementary_school, :with_hub_city_mapping, collection_id:5) }


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

    scenario 'Summer program should not appear since it does not have a collection' do
      expect(subject).to_not have_content('Summer_program')
    end
  end

  context 'When on All Grade School' do
    let(:school) { FactoryGirl.create(:a_prek_elem_middle_high_school, :with_hub_city_mapping, collection_id:5) }

    scenario 'Summer program should appear since it includes level code e,m' do
      expect(subject).to have_content('Summer_program')
    end
  end

  context 'When on Elementary School' do
    let(:school) { FactoryGirl.create(:an_elementary_school, :with_hub_city_mapping, collection_id:5) }
    scenario 'Summer program should appear since it has level code e' do
      expect(subject).to have_content('Summer_program')
    end
  end

  context 'When on a High School' do
    let(:school) { FactoryGirl.create(:a_high_school) }

    scenario 'Summer program should not appear since it has level code h' do
      expect(subject).to_not have_content('Summer_program')
    end
  end

end
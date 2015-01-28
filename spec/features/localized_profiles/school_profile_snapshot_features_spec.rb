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
    clean_models :ca, School, EspResponse, SchoolMetadata, CensusDataSet,
                      CensusDataSchoolValue, District
    clean_models  User, Page, Category, CategoryData, CategoryPlacement,
                  HubCityMapping, CensusDataType
  end

  subject do
    visit school_path(school)
    page
  end

  context 'With any snapshot that shows summer programs' do
    let(:school) { FactoryGirl.create(:an_elementary_school, :with_hub_city_mapping, collection_id:5) }


    scenario 'Snapshot label is displayed and capitalized' do
      pending('pending until the intermittent failure is fixed')
      fail
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
        pending('pending until the intermittent failure is fixed')
        fail
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
        pending('pending until the intermittent failure is fixed')
        fail
        expect(subject).to have_content('Summer_program Yes')
      end
    end

    context 'When there\'s not esp data for summer program' do
      let(:summer_program_esp_response) { }

      scenario 'Summer program displays value of "no info"' do
        pending('pending until the intermittent failure is fixed')
        fail
        expect(subject).to have_content('Summer_program no info')
      end
    end
  end

  context 'When on Alameda High School' do
    let(:school) { FactoryGirl.create(:alameda_high_school) }

    scenario 'Summer program should not appear since it does not have a collection' do
      pending('pending until the intermittent failure is fixed')
      fail
      expect(subject).to_not have_content('Summer_program')
    end
  end

  context 'When on All Grade School' do
    let(:school) { FactoryGirl.create(:a_prek_elem_middle_high_school, :with_hub_city_mapping, collection_id:5) }

    scenario 'Summer program should appear since it includes level code e,m' do
      pending('pending until the intermittent failure is fixed')
      fail
      expect(subject).to have_content('Summer_program')
    end
  end

  context 'When on Elementary School' do
    let(:school) { FactoryGirl.create(:an_elementary_school, :with_hub_city_mapping, collection_id:5) }
    scenario 'Summer program should appear since it has level code e' do
      pending('pending until the intermittent failure is fixed')
      fail
      expect(subject).to have_content('Summer_program')
    end
  end

  context 'When on a High School' do
    let(:school) { FactoryGirl.create(:a_high_school) }

    scenario 'Summer program should not appear since it has level code h' do
      pending('pending until the intermittent failure is fixed')
      fail
      expect(subject).to_not have_content('Summer_program')
    end
  end

  context 'When an enrollment value exists for Alameda High School' do
    let(:school) { FactoryGirl.create(:alameda_high_school) }

    before do
      FactoryGirl.create(
        :enrollment_data_set,
        :with_school_value,
        school_id: school.id,
        school_value_float: 100
      )

      FactoryGirl.create(
        :category_data,
        category: snapshot,
        response_key: 'enrollment',
        label: 'Enrollment',
        source: 'census_data_points'
      )

      @data_type = FactoryGirl.create(
        :census_data_type,
        id: 17,
        description: 'Enrollment'
      )
    end

    scenario 'Enrollment should appear with the right value' do
      pending('pending until the intermittent failure is fixed')
      fail
      allow_any_instance_of(CensusDataSet)
        .to receive(:census_data_type).and_return @data_type
      expect(subject).to have_content('Enrollment 100')
    end
  end

  context 'When school has a district called "Alameda City Unified"' do
    let(:school) do
      FactoryGirl.create(
        :alameda_high_school,
        :with_district,
        district_name: 'Alameda City Unified'
      )
    end
    before do
      FactoryGirl.create(
        :category_data,
        category: snapshot,
        response_key: 'district',
        label: 'District',
        source: 'school_data'
      )
    end
    scenario 'District data point should appear' do
      expect(subject).to have_content('District Alameda City Unified')
    end

    scenario 'District name should link to district home' do
      subject
      click_link 'Alameda City Unified'
      uri = URI.parse(current_url)
      expect(uri.path).to eq city_district_path(
        district_params_from_district(school.district)
      )
    end
  end

end

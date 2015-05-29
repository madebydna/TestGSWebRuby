require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe CensusLoading::Loader do

  it_behaves_like 'a loader', CensusLoading::Loader

  describe '#insert_into!' do

    let(:data_type) { FactoryGirl.create(:census_data_type) }
    let(:loader) { CensusLoading::Loader.new(nil, nil, 'fake source') }
    let(:school) { FactoryGirl.create(:school) }
    let(:update) {
      {
          entity_state: 'CA',
          source: 'CA Dept. of Fake',
          entity_type: :school,
          entity_id: school.id,
          value: 23,
          created:'2015-05-13 11:50:40'

      }
    }
    let(:census_update) { CensusLoading::Update.new(data_type, update) }

    after do
      clean_models :ca, School
      clean_models :ca, District
      clean_models CensusDescription
      clean_models CensusDataType
    end
    after(:each) do
      clean_models :ca, CensusDataSet
      clean_models :ca, CensusDataSchoolValue
      clean_models :ca, CensusDataDistrictValue
      clean_models :ca, CensusDataStateValue
    end

    context 'the census data value' do
      after(:each) do
        clean_models :ca, CensusDataSet
        clean_models :ca, CensusDataSchoolValue
        clean_models :ca, CensusDataDistrictValue
        clean_models :ca, CensusDataStateValue
      end
      ['2010-05-14 13:30:01.000000000 -0700', nil].each do |created_time|
        [:school,:district,:state].each do |entity_type|
          context "for #{entity_type} level data and created time #{created_time}" do
            let(:update) {
              {
                  entity_state: 'CA',
                  source: 'OSP Form',
                  entity_type: entity_type,
                  entity_id: 1,
                  value: 23,
                  created: created_time

              }
            }
            let(:census_update) { CensusLoading::Update.new(data_type, update) }
            before do
              unless entity_type == :state
                entity = FactoryGirl.create(entity_type, id: update[:entity_id])
              end
              @data_set = FactoryGirl.create(:census_data_set)
              @data_value = FactoryGirl.create("census_data_#{entity_type}_value_with_newer_data".to_sym)
              value_class = "CensusData#{entity_type.to_s.titleize}Value".constantize
              allow(CensusDataSet).to receive(:find_or_create_and_activate).and_return(@data_set)
              allow(value_class).to   receive(:first_or_initialize).and_return(@data_value)
              loader.insert_into!(census_update, entity)
              # require 'pry'; binding.pry if entity_type == :district
              @value_row = value_class.on_db(census_update.shard).order(modified: :desc).first
            end

            it 'should be inserted based on time' do
              if created_time.nil?
                expect(@value_row.value_float).to eq(23)
              else
                expect(@value_row.value_float).to eq(@data_value.value_float)

              end
            end
          end
          end
      end
    end

    context 'data set' do
      it 'should be for the correct attributes' do
        @data_set = FactoryGirl.create(:census_data_set)
        allow(CensusDataSet).to receive(:find_or_create_and_activate).and_return(@data_set)
        expect(CensusDataSet).to receive(:find_or_create_and_activate).with(census_update.shard, census_update.data_set_attributes)
        loader.insert_into!(census_update, school)
      end
    end

    context 'the census description row' do
      it 'should be for the correct attributes' do
        data_set = FactoryGirl.create(:census_data_set)
        allow(CensusDataSet).to receive(:find_or_create_and_activate).and_return(data_set)
        census_description = FactoryGirl.create(:census_description)
        allow(CensusDescription).to receive(:where).and_return(CensusDescription)
        allow(CensusDescription).to receive(:first_or_create!).and_return(census_description)
        census_description_attributes = {
            census_data_set_id: data_set.id,
            state: census_update.entity_state,
            school_type: school.type,
            source: census_update.source,
            type: census_update.entity_type
        }
        expect(CensusDescription).to receive(:where).with(census_description_attributes)
        loader.insert_into!(census_update, school)
      end
    end

    context 'the created value row' do
      [:school, :district, :state].each do |entity_type|
        context "for #{entity_type} level data" do
          let(:update) {
            {
              entity_state: 'CA',
              source: 'CA Dept. of Fake',
              entity_type: entity_type,
              entity_id: 100,
              value: 23,
              created:'2015-05-14 13:30:01.000000000 -0700'

            }
          }
          let(:census_update) { CensusLoading::Update.new(data_type, update) }
          before do
            unless entity_type == :state
              entity = FactoryGirl.create(entity_type, id: update[:entity_id])
            end
            @data_set = FactoryGirl.create(:census_data_set)
            allow(CensusDataSet).to receive(:find_or_create_and_activate).and_return(@data_set)
            loader.insert_into!(census_update, entity)
            value_class = "CensusData#{entity_type.to_s.titleize}Value".constantize
            @value_row = value_class.on_db(census_update.shard).last
          end

          it 'should be active' do
            expect(@value_row.active).to eq(1)
          end

          it 'should have the correct data_set_id' do
            expect(@value_row.data_set_id).to eq(@data_set.id)
          end

          it 'should have the correct modified time' do
            expect(@value_row.modified).to eq(census_update.created)
          end

          unless entity_type == :state
            it 'should have the correct entity_id' do
              expect(@value_row.send(census_update.entity_id_type)).to eq(census_update.entity_id)
            end
          end

          it 'should have the correct value' do
            expect(@value_row.send(census_update.value_type)).to eq(census_update.value)
          end

          it 'should have the correct modifiedBy' do
            expect(@value_row.modifiedBy).to eq('fake source')
          end
        end
      end
    end
  end

end

require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe SchoolLoading::Loader do


  describe '#school_insert' do
    let(:subject) { SchoolLoading::Loader.new(nil, nil, 'osp_form') }


    after do
      clean_models :ca, EspResponse
      clean_models OspFormResponse
      clean_models UpdateQueue
      clean_models School
      clean_models :ca, School
      clean_models User, UserProfile
    end

    context 'when inserting newer data than the db has' do
      let(:value_row) { [FactoryGirl.build(:alameda_high_school, modified: '2015-01-30 18:36:29 -0700', id: 2)] }

      let(:update) {
        {
            entity_state: "ca",
            entity_id: 2,
            entity_type: "school",
            value: "http://www.google.com",
            member_id: 27620,
            created:'2015-05-26 18:36:29 -0700',
            source: "manually entered by school official"
        }
      }
      let(:school_update) { SchoolLoading::Update.new('home_page_url', update) }


      it 'should have the correct value' do
        subject.load!
        School.on_db(:ca).all.each do |response|
          expect(response.home_page_url).to eq(school_update.value)
        end
      end
      it 'should have the correct modified time' do
        subject.load!
        School.on_db(:ca).all.each do |response|
          expect(response.modified).to eq(school_update.created)
        end
      end
    end
    context 'when inserting older data than the db has' do
      let(:value_row) { [FactoryGirl.build(:alameda_high_school, modified: '2015-05-26 18:36:29 -0700', id: 2, home_page_url: 'www.testing.com')] }
      let(:update) {
        {
            entity_state: "ca",
            entity_id: 2,
            entity_type: "school",
            value: "http://www.google.com",
            member_id: 27620,
            created:'2015-01-30 18:36:29 -0700',
            source: "manually entered by school official"
        }
      }
      let(:school_update) { SchoolLoading::Update.new('home_page_url', update) }

      it 'should not change modified time of existing row' do
        subject.load!
        School.on_db(:ca).all.each do |response|
          expect(response.created).to eq(value_row.modified)
        end
      end
      it 'should not change value of existing row' do
        subject.load!
        School.on_db(:ca).all.each do |response|
          expect(response.home_page_url).to eq(school_update.value)
        end
      end
    end

  end

end
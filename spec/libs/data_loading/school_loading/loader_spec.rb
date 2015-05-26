require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe SchoolLoading::Loader do


  describe '#school_insert' do


    after do
      clean_models :ca, EspResponse
      clean_models OspFormResponse
      clean_models UpdateQueue
      clean_models School
      clean_models :ca, School
      clean_models User, UserProfile
    end

    context 'when inserting newer data than the db ' do


      let(:update) {
        {
            entity_state: "ca",
            entity_id: 1,
            entity_type: "school",
            value: "http://www.google.com",
            member_id: 27620,
            created:'2015-05-26 18:36:29 -0700',
            source: "manually entered by school official"
        }.stringify_keys
      }
      let(:school_loader) { SchoolLoading::Loader.new('home_page_url', [update], 'osp_form') }

      before do
        @school= FactoryGirl.create(:alameda_high_school, modified: '2015-01-30 18:36:29 -0700', id: 1, home_page_url: 'not real')
      end

      it 'should have the correct value' do
        school_loader.load!
        updated_school = School.on_db(:ca).find(1)

        expect(updated_school.home_page_url).to eq(update['value'])
      end
      it 'should have the correct modified time' do
        school_loader.load!
        updated_school = School.on_db(:ca).find(1)
        expect(updated_school.modified).to eq(update['created'])
      end
    end
    context 'when inserting older data than the db ' do


      let(:update) {
        {
            entity_state: "ca",
            entity_id: 1,
            entity_type: "school",
            value: "http://www.google.com",
            member_id: 27620,
            created:'2014-05-26 18:36:29 -0700',
            source: "manually entered by school official"
        }.stringify_keys
      }
      let(:school_loader) { SchoolLoading::Loader.new('home_page_url', [update], 'osp_form') }

      before do
        @school= FactoryGirl.create(:alameda_high_school, modified: '2015-01-30 18:36:29 -0700', id: 1, home_page_url: 'not real')
      end

      it 'should have the correct value' do
        school_loader.load!
        updated_school = School.on_db(:ca).find(1)

        expect(updated_school.home_page_url).to eq(@school.home_page_url)
      end
      it 'should have the correct modified time' do
        school_loader.load!
        updated_school = School.on_db(:ca).find(1)
        expect(updated_school.modified).to eq(@school.modified)
      end
    end


  end

end
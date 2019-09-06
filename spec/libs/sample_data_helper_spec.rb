require 'spec_helper'

describe 'sample_data_helper.rb' do
  require 'sample_data_helper'

  describe 'load_sample_data' do
    after(:each) { do_clean_dbs :ca }

    it 'should load a single school' do
      load_sample_data 'sample_data_helper_test'
      schools = School.on_db(:ca).all
      expect(schools.size).to eq 1
      expect(schools.first.name).to eq 'Alameda High School'
    end

    it 'should load a single school again' do
      load_sample_data 'sample_data_helper_test'
      schools = School.on_db(:ca).all
      expect(schools.size).to eq 1
      expect(schools.first.name).to eq 'Alameda High School'
    end
  end
end

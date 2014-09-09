require 'spec_helper'
require_relative 'compare_schools_spec_helper'

describe 'Compare Schools Page' do
  include CompareSchoolsSpecHelper

  # before block for non webkit tests
  # before do
  #   allow_any_instance_of(CompareSchoolsController).to receive(:params).and_return({state: :ca})
  #   allow_any_instance_of(CompareSchoolsController).to receive(:decorated_schools).and_return(decorated_schools_mock)
  #   allow_any_instance_of(CompareSchoolsController).to receive(:prepare_map)
  # end

  # Since this code requires JS it will execute using webkit capybara
  # As a result, to get this test working you will need to make a school cache factory and save it to the db before running this test
  # Currently as constructed the test below uses the development db and not test db to get the school cache data

  # context 'when showing multiple schools', js: true do
  #   before do
  #     create_set_of_school_caches!
  #     create_set_of_aligned_schools!
  #   end
  #   after(:each) do
  #     clean_models :ca, School
  #     SchoolCache.destroy_all
  #   end
  #   let(:heights) do
  #     heights = [0, 1, 2, 3].map do |number|
  #       page.evaluate_script("$(\'.js-comparedSchool#{number}\').height()")
  #     end
  #     heights.reject! { |number| number.class != Fixnum}
  #   end
  #
  #   it 'should have aligned columns even when there is a school with a 2 line grade level' do
  #     create_school_cache_set_in_db!(4, :ca)
  #     create_school_with_long_grade_level!
  #     visit compare_schools_path school_ids: '1, 2, 3, 4', state: :ca
  #     expect(heights.uniq.count).to eq 1
  #   end
  #
  #   it 'should have aligned columns even when there is a school with a multline name' do
  #     create_school_cache_set_in_db!(4, :ca)
  #     create_school_with_long_name!
  #     visit compare_schools_path school_ids: '1, 2, 3, 4', state: :ca
  #     expect(heights.uniq.count).to eq 1
  #   end
  #
  #   it 'should have aligned columns even when there is a school cache with a blank pie chart (no ethnicity data)' do
  #     FactoryGirl.create(:school, :with_levels, id: 4)
  #     create_school_cache_data_with_no_ethnicity_data!
  #     visit compare_schools_path school_ids: '1, 2, 3, 4', state: :ca
  #     expect(heights.uniq.count).to eq 1
  #   end
  #
  #   it 'should have aligned columns even when there is a school cache with a long ethnicity breakdown' do
  #     FactoryGirl.create(:school, :with_levels, id: 4)
  #     create_school_cache_data_with_long_ethnicity!
  #     visit compare_schools_path school_ids: '1, 2, 3, 4', state: :ca
  #     expect(heights.uniq.count).to eq 1
  #   end

  # end
end
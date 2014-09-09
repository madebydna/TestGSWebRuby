require 'spec_helper'
require_relative 'compare_schools_spec_helper'

describe 'Compare Schools Page' do
  include CompareSchoolsSpecHelper

  before do
    allow_any_instance_of(CompareSchoolsController).to receive(:params).and_return({state: :de})
    allow_any_instance_of(CompareSchoolsController).to receive(:decorated_schools).and_return(decorated_schools_mock)
    allow_any_instance_of(CompareSchoolsController).to receive(:prepare_map)
  end

  # context 'when showing multiple schools', js: true do
  #   let(:heights) do
  #     heights = [0, 1, 2, 3].map do |number|
  #       page.evaluate_script("$(\'.js-comparedSchool#{number}\').height()")
  #     end
  #     heights.reject! { |number| number.class != Fixnum}
  #   end
  #
  #   it 'should have aligned columns even when there is a school with a 2 line grade level' do
  #     visit compare_schools_path school_ids: '1, 20, 68', state: :dc
  #     expect(heights.uniq.count).to eq 1
  #   end
  #
  #   it 'should have aligned columns even when there is a school with a multline name' do
  #     visit compare_schools_path school_ids: '1, 15, 20', state: :dc
  #     expect(heights.uniq.count).to eq 1
  #   end
  #
  #   it 'should have aligned columns even when there is a school with a blank pie chart' do
  #     visit compare_schools_path school_ids: '1, 20, 1029', state: :dc
  #     expect(heights.uniq.count).to eq 1
  #   end
  # end
end
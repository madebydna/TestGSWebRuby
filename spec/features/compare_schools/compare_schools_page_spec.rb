require 'spec_helper'
require_relative 'compare_schools_spec_helper'

describe 'Compare Schools Page' do
  include CompareSchoolsSpecHelper

  before do
    allow_any_instance_of(CompareSchoolsController).to receive(:params).and_return({state: :de})
    allow_any_instance_of(CompareSchoolsController).to receive(:decorated_schools).and_return(decorated_schools_mock)
    allow_any_instance_of(CompareSchoolsController).to receive(:prepare_map)
    visit compare_schools_path
  end

  it 'should display columns that are aligned' do
  end
end
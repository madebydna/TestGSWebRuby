require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

describe SchoolProfileDecorator do
  it_behaves_like 'a school that has grade levels' do
    let(:school) { SchoolProfileDecorator.decorate(FactoryGirl.build(:school)) }
  end
end

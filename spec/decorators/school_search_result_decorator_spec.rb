require 'spec_helper'
require 'decorators/concerns/grade_level_concerns_shared'

describe SchoolSearchResultDecorator do
  it_behaves_like 'a school that has grade levels' do
    let(:school) { SchoolSearchResultDecorator.decorate(FactoryGirl.build(:school_search_result)) }
  end
end

require 'spec_helper'

describe SearchController do
  it 'should include PaginationConcerns' do
    expect(SearchController.ancestors.include?(PaginationConcerns)).to be_truthy
  end
end
require 'spec_helper'

describe 'admin/schools/_review.html.erb' do
  let(:review) { FactoryGirl.build(:review, created: '2000-01-01') }

  it 'should display a review posted date' do
    allow(view).to receive(:review) { review }

    render

    expect(rendered).to match /January 01, 2000/
  end

end

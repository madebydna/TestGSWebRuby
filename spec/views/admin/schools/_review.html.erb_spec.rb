require 'spec_helper'

describe 'admin/schools/_review.html.erb' do
  let(:review) { FactoryGirl.build(:school_rating, posted: '2000-01-01') }

  it 'should display a review posted date' do
    allow(view).to receive(:review) { review }

    render

    expect(rendered).to match /January 01, 2000/
  end

end

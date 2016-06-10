require 'spec_helper'

describe 'admin/schools/_review_flags_table.html.erb' do
  let(:review) {
    double(
      user: nil 
    )
  }
  let(:review_flags) do
    [
      double(
        reason: 'Review with teacher names',
        comment: 'This review mentions a teacher\'s name!',
        created: Time.now,
        user: double(
          email: 'foo@example.com',
        ),
        review: review
      )
    ]
  end
  before do
    allow(view).to receive(:css_class) { 'foo' }
    allow(view).to receive(:review_flags) { review_flags }
  end

  it 'should render the reason' do
    render
    expect(rendered).to match(/Review with teacher names/)
  end

  context 'when the flagged review has no user' do
    before { allow(review).to receive(:user).and_return(nil) }
    it 'should not error' do
      expect { render }.to_not raise_error
    end
    it 'should let the user know the review has no user' do
      render
      expect(rendered).to match(/Review with teacher names/)
    end
  end

end

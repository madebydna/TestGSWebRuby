require 'spec_helper'

describe 'cities/_programs_sponsor.html.erb' do
  context 'with missing or malformed data' do
    it 'does not error out' do
      view.stub(:sponsor) { nil }
      expect { render }.to_not raise_error
    end
  end
end

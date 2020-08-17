require 'spec_helper'

describe Api::ViewHelper do
  let(:free_plan) {create(:api_plan)}
  let(:all_you_can_eat_plan) {create(:api_plan, name: 'extreme_plan', price: 1000)}
  let(:user) {create(:api_user)}
  let(:subscription) { create(:api_subscription, plan: free_plan, user: user) }
  let(:subscription2) { create(:api_subscription, plan: all_you_can_eat_plan, user: user) }
  describe '#format_text' do
    [
      ['data scientist', 'Data Scientist'],
      ['software engineer', 'Software Engineer'],
      ['real estate agent', 'Real Estate Agent'],
      [nil, 'N/A'],
    ].each do |text, result|
      it "return the formatted form of #{text}" do
        expect(format_text(text)).to eq(result)
      end
    end
  end

  describe '#format_plan' do
    it 'returns the correct plan' do
      [
        [subscription, 'Free Trial $0.00/month'],
        [subscription2, 'Extreme Plan $1,000.00/month'],
        [nil, 'No Plan Selected'],
      ].each do |plan, result|
        expect(format_plan(plan)).to eq(result)
      end
    end
  end
end
require 'spec_helper'

describe Api::ViewHelper do
  let(:free_plan) {create(:api_plan)}
  let(:all_you_can_eat_plan) {create(:api_plan, name: 'extreme_plan', price: 1000)}
  let(:user) {create(:api_user)}
  let(:subscription) { create(:api_subscription, plan: free_plan, user: user) }
  let(:subscription2) { create(:api_subscription, plan: all_you_can_eat_plan, user: user) }
  let(:card_details) { OpenStruct.new(brand: 'visa', last_four: '4242') }

  describe '#capitalize_words' do
    [
      ['data scientist', 'Data Scientist'],
      ['software engineer', 'Software Engineer'],
      ['real estate agent', 'Real Estate Agent'],
      [nil, 'N/A'],
    ].each do |text, result|
      it "return the formatted form of #{text}" do
        expect(capitalize_words(text)).to eq(result)
      end
    end
  end

  describe '#format_plan' do
    it 'returns the correct plan' do
      [
        [subscription, 'Free Trial $0.00/month'],
        [subscription2, 'Extreme Plan $1,000.00/month'],
        [nil, 'No Plan Selected'],
      ].each do |subscription, result|
        expect(format_plan(subscription&.plan)).to eq(result)
      end
    end
  end

  describe '#display_credit_card' do
    it 'returns the right credit card image' do
      expect(display_credit_card(card_details)).to eq("<img src=\"/images/icons/credit-card-2.svg\" alt=\"Credit card 2\" />")
    end
  end

  describe '#display_card_information' do
    it 'should return N/A if details are empty' do
      expect(display_card_information(nil)).to eq('N/A')
    end

    it 'should return the correct phrase' do
      expect(display_card_information(card_details)).to eq('Visa ending in 4242')
    end
  end
end
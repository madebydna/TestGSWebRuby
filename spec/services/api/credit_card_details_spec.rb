require "spec_helper"

describe Api::CreditCardDetails do
  let(:card_details) { {
    brand: 'visa',
    country: 'US',
    funding: 'credit',
    last4: '4242'
  }}

  let(:billing_details) {{
    name: 'Biscuit',
    address: {
      city: 'Los Angeles',
      line1: '1234 Anywhere St',
      line2: '#B',
      postal_code: '92126',
      state: 'ca'
    }
  }}

  subject { Api::CreditCardDetails.call(card_details, billing_details) }

  describe '#.call' do
    it 'should be valid' do
      expect { to be_valid }
    end

    context 'with a valid cc' do
      it '#last_four' do
        expect(subject.last_four).to eq('4242')
      end

      it '#brand' do
        expect(subject.brand).to eq('visa')
      end

      it '#name' do
        expect(subject.name).to eq('Biscuit')
      end

      it '#address' do
        expect(subject.address).to eq('1234 Anywhere St #B')
      end

      it '#locality' do
        expect(subject.locality).to eq('Los Angeles, CA')
      end

      it '#zipcode' do
        expect(subject.zipcode).to eq('92126')
      end
    end
  end

end
# frozen_string_literal: true

require_relative '../../validations/minimum'

# rubocop:disable BlockLength
describe Minimum do
  let(:subject) { Minimum.new(value_column, minimum) }
  let(:value_column) { :value }
  let(:minimum) { 23 }

  describe '#process' do
    context 'with value below minimum' do
      let(:row) { { value: 22 } }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: 22, error: "Value: 22 is less than the minimum 23\n" })
      end
    end

    context 'with value in range' do
      let(:row) { { value: 25 } }
      it 'should return the row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 25 })
      end
    end

    context 'with value nil' do
      let(:row) { { value: nil } }
      it 'should return ran error' do
        output = subject.process(row)
        expect(output).to eq({ value: nil, error: "Value:  is less than the minimum 23\n" })
      end
    end
  end
end
# rubocop:enable BlockLength
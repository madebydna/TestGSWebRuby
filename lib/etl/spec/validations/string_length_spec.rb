# frozen_string_literal: true

require_relative '../../validations/string_length'

describe StringLength do
  let(:subject) { StringLength.new(value_column, str_len) }
  let(:value_column) { :value }
  let(:str_len) { 3 }

  describe '#process' do
    context 'with value length not equal and int' do
      let(:row) { { value: 10 } }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: 10, error: "String length for value 10 does not equal 3\n" })
      end
    end

    context 'with value is correct length as string' do
      let(:row) { { value: '201' } }
      it 'should return the row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: '201' })
      end
    end

    context 'with value is correct length as int' do
      let(:row) { { value: 101 } }
      it 'should return the row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 101 })
      end
    end

    context 'with value length not equal and string' do
      let(:row) { { value: '9090' } }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: '9090', error: "String length for value 9090 does not equal 3\n" })
      end
    end

    context 'with value nil' do
      let(:row) { { value: nil } }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: nil, error: "String length for value  does not equal 3\n" })
      end
    end
  end
end
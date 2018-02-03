# frozen_string_literal: true

require_relative '../../validations/range_check'

# rubocop:disable BlockLength
describe RangeCheck do
  let(:subject) { RangeCheck.new(value_column, hash) }
  let(:value_column) { :value }
  let(:hash) {{bottom:0,top:100,exceptions_array: %w(<2 >95)}}

  describe '#process' do
    context 'with value out of range' do
      let(:row) { { value: 101 } }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: 101, error: "Error out of range value: 101 against range 0-100 and exceptions <2,>95\n" })
      end
    end

    context 'with value in range' do
      let(:row) { { value: 1 } }
      it 'should return the row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 1 })
      end
    end

    context 'with value not in range but part of exceptions' do
      let(:row) { { value: '<2' } }
      it 'should return row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: '<2' })
      end
    end
  end
end
# rubocop:enable BlockLength
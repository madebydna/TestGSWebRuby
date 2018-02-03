# frozen_string_literal: true

require_relative '../../validations/type_check'

# Possible types to use
# TrueClass
# FalseClass
# String
# Integer
# Float
# Bignum
# Symbol
# Array
# Hash

# rubocop:disable BlockLength
describe TypeCheck do
  let(:subject) { TypeCheck.new(value_column, type) }
  let(:value_column) { :value }

  describe '#process' do
    context 'with value mismatch int and float' do
      let(:row) { { value: 101 } }
      let(:type) { Float }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: 101, error: "Error: Type mismatch 101:Float\n" })
      end
    end

    context 'with value match int and int' do
      let(:row) { { value: 101 } }
      let(:type) { Integer }
      it 'should return row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 101 })
      end
    end

    context 'with value mismatch string and int' do
      let(:row) { { value: '101' } }
      let(:type) { Integer }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: '101', error: "Error: Type mismatch 101:Integer\n" })
      end
    end

    context 'with value match string and string' do
      let(:row) { { value: 'help' } }
      let(:type) { String }
      it 'should return row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 'help' })
      end
    end

    context 'with value match hash and hash' do
      let(:row) { { value: { help: 101 } } }
      let(:type) { Hash }
      it 'should return row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: { help: 101 }})
      end
    end

  end
end
# rubocop:enable BlockLength
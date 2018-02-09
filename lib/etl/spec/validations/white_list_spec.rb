# frozen_string_literal: true

require_relative '../../validations/white_list'

describe WhiteList do
  let(:subject) { WhiteList.new(value_column, *white_list) }
  let(:value_column) { :value }
  let(:white_list) { ['help', 22, '22'] }

  describe '#process' do
    context 'with value not in white list' do
      let(:row) { { value: 101 } }
      it 'should return an error' do
        output = subject.process(row)
        expect(output).to eq({ value: 101, error: "Error checking value: 101 is not in the white list: #{white_list.join(',')}" })
      end
    end

    context 'with value in white list' do
      let(:row) { { value: 22 } }
      it 'should return the row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 22 })
      end
    end

    context 'with value in white list' do
      let(:row) { { value: 'help' } }
      it 'should return row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ value: 'help' })
      end
    end
  end
end
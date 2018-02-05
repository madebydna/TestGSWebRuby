# frozen_string_literal: true

require_relative '../../validations/columns_with_required_values'

describe ColumnsWithRequiredValues do
  let(:subject) { ColumnsWithRequiredValues.new(*input_columns) }
  let(:input_columns) { %i(column1 column2 column3) }

  describe '#process' do
    context 'with columns passed as args' do
      let(:row) { { column1: 101, column2: 222,  column3: '898' } }
      it 'should return row unchanged' do
        output = subject.process(row)
        expect(output).to eq({ column1: 101, column2: 222, column3: '898' })
      end
    end

    context 'with one column as nil' do
      let(:row) { { column1: nil, column2: 222,  column3: '898' } }
      it 'should return row with error' do
        output = subject.process(row)
        expect(output).to eq({ column1: nil, column2: 222,  column3: '898', error: "These columns do not have values: column1\n" })
      end
    end

    context 'with one column missing' do
      let(:row) { { column2: 222, column3: '898' } }
      it 'should return row with error' do
        output = subject.process(row)
        expect(output).to eq({ column2: 222, column3: '898', error: "These columns do not have values: column1\n" })
      end
    end

    context 'with one column missing and one empty' do
      let(:row) { { column2: '', column3: 0 } }
      it 'should return row with error' do
        output = subject.process(row)
        expect(output).to eq({ column2: '', column3: 0, error: "These columns do not have values: column1,column2\n" })
      end
    end
  end
end
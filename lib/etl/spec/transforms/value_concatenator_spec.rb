require_relative '../../transforms/value_concatenator'

# 1 take ids or column names that we are concatenating
# 2 create a new column name
# 3 enter concatenated values for all columns from step 1 into new column

describe ValueConcatenator do
  let(:source_column) { :source }
  let(:source_column2) { :source2 }
  context 'with output row' do
    let(:subject) { ValueConcatenator.new(:output, source_column, source_column2) }
    let(:row) { { source: 'badda', source2: 'bing' } }
    let(:output_row) { {source: 'badda', source2: 'bing', output: 'baddabing' } }

    it 'should concatonate source columns' do
      expect(subject.process(row)).to eq(output_row)
    end
  end

end

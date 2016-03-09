require 'spec_helper'

# 1 take ids or column names that we are concating
# 2 create a new column name
# 3 enter concataned values for all columns from step 1 into new column

describe ValueConcatonator do
  let(:source_column) { :source }
  let(:source_column2) { :source2 }
  context 'with output row' do
    let(:subject) { ValueConcatonator.new(:output, source_column, source_column2) }
    let(:row) { { source: 'badda', source2: 'bing' } }
    let(:output_row) { {source: 'badda', source2: 'bing', output: 'baddabing' } }

    it 'should concatonate source columns' do
      expect(subject.process(row)).to eq(output_row)
    end
  end

end



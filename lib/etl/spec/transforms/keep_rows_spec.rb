require_relative '../../transforms/keep_rows'

describe KeepRows do
    let(:subject) { KeepRows.new(:field, *values_to_match).process(row) }
    context 'with value found in values to match' do
      let(:values_to_match) { [1,4] }
      let(:row) { {field: 1} }
      it { is_expected.to eq(row) }
    end
    context 'with value not found in values to match' do
      let(:values_to_match) { [2] }
      let(:row) { {field: 1} }
      it { is_expected.to eq(nil) }
    end
end

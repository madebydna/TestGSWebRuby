require 'spec_helper'

describe KeepRows do
  context 'without duplicate values in field' do
    let(:subject) { KeepRows.new(values_to_match, :field).process(row) }
    context 'with value found in values to match' do
      let(:values_to_match) { [1] }
      let(:row) { {field: 1} }

      it { is_expected.to eq(row) }
    end
    context 'with value not found in values to match' do
      let(:values_to_match) { [2] }
      let(:row) { {field: 1} }
      it { is_expected.to eq(nil) }
    end
  end
end

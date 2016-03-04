require 'spec_helper'

describe FilterOutMatchingValues do
  context 'without duplicate values in field' do
    let(:subject) { FilterOutMatchingValues.new(values_to_match, :field).process(row) }
    context 'with value found in values to match' do
      let(:values_to_match) { [1] }
      let(:row) { {field: 1} }

      it { is_expected.to eq(nil) }
    end
    context 'with value not found in values to match' do
      let(:values_to_match) { [2] }
      let(:row) { {field: 1} }
      it { is_expected.to eq(row) }
    end
  end
  context 'with duplicate values in field' do
    let(:subject) {  FilterOutMatchingValues.new(values_to_match, :field) }
    let(:rows) { [{field: 1},{field: 1}] }
    let(:values_to_match) { [2] }
    context 'with value not in found in values to match' do
      it 'should only return one of the duplicate rows' do
        results = rows.map { |row| subject.process(row) }
        expect(results).to eq([{field:1}, nil])
      end
    end
  end
end

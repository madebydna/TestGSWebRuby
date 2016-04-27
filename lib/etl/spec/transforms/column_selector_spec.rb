require 'spec_helper'

describe ColumnSelector do
  let(:subject) { ColumnSelector.new(*columns_selected).process(row) }
  context 'with columns found in source' do
    let(:columns_selected) { [:test, :name] }
    let(:row) { {field: 1, test: 2, name: 4} }
    it { is_expected.to eq( {test: 2, name: 4} ) }
  end
  context 'with columns found in source with regex' do
    let(:columns_selected) { [/^t/, :name] }
    let(:row) { {field: 1, test: 2, name: 4} }
    it { is_expected.to eq( {test: 2, name: 4} ) }
  end
  context 'with columns selected value not found in source' do
    let(:columns_selected) { [:test, :buddy] }
    let(:row) { {field: 1, test: 2, name: 4} }
    it { is_expected.to eq( {test: 2} ) }
  end
end

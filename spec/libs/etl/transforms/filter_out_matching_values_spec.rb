require 'spec_helper'

describe FilterOutMatchingValues do
  let(:subject) { FilterOutMatchingValues.new(:field, *values_to_match).process(row) }
  context 'with value found in string values to match' do
    let(:values_to_match) { ['one'] }
    let(:row) { {field: 'one'} }

    it { is_expected.to eq(nil) }
  end
  context 'with value not found in string values to match' do
    let(:values_to_match) { ['two'] }
    let(:row) { {field: 'one'} }
    it { is_expected.to eq(row) }
  end

  context 'with value found in regex values to match' do
    let(:values_to_match) { [/^male_*/i] }
    let(:row) { {field: 'Male_Asian'} }
    it { is_expected.to eq(nil) }
  end
  context 'with value not found in regex values to match' do
    let(:values_to_match) { [/^male_*/i] }
    let(:row) { {field: 'Fem_HISP'} }
    it { is_expected.to eq(row) }
  end
end

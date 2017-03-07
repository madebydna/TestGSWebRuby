require 'spec_helper'

describe 'TestScoreCalculations' do

  describe '#select_items_with_max_year!' do
    subject { data.select_items_with_max_year!; data }

    context 'with various years' do
      let(:data) do
        [
          { 'year' => 0 },
          { 'year' => 2010 },
          { 'year' => nil },
          { 'year' => 2002 }
        ].extend(TestScoreCalculations)
      end
      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to include('year' => 2010) }
    end

    context 'with all same years' do
      let(:data) do
        [
          { 'year' => 2010 },
          { 'year' => 2010 },
          { 'year' => 2010 }
        ].extend(TestScoreCalculations)
      end
      its(:length) { is_expected.to eq(3) }
      it 'should have all the same years' do
        years = subject.map { |o| o['year'] }
        expect(years.all? { |y| y == 2010 }).to be true
      end
    end

  end

end

require 'spec_helper'

describe 'TestScoreCalculations' do

  describe '#select_items_with_max_year!' do
    subject { data.select_items_with_max_year!; data }

    context 'with various years' do
      let(:data) do
        [
          { 'date_valid' => 0 },
          { 'date_valid' => '00000000' },
          { 'date_valid' => '20100101' },
          { 'date_valid' => nil },
          { 'date_valid' => '20020101' }
        ].extend(TestScoreCalculations)
      end
      its(:length) { is_expected.to eq(1) }
      # require 'pry';binding.pry;
      its(:first) { is_expected.to include('date_valid' => '20100101') }
    end

    context 'with all same years' do
      let(:data) do
        [
          { 'date_valid' => '20100101' },
          { 'date_valid' => '20100101' },
          { 'date_valid' => '20100101' }
        ].extend(TestScoreCalculations)
      end
      its(:length) { is_expected.to eq(3) }
      it 'should have all the same years' do
        years = subject.map { |o| o['date_valid'] }
        expect(years.all? { |y| y == '20100101' }).to be true
      end
    end

  end

end

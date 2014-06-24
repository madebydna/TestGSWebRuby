require 'spec_helper'

describe BarCharts::TestScoresBarChart, type: 'model' do
  let(:bar_charts) { BarCharts::TestScoresBarChart.new({}) }

  describe '#array_for_single_bar' do
    subject { test_scores_bar_chart.array_for_single_bar('90', 'prefix') }

    it 'adds the correct tooltip to the array' do
      expect(subject[2]).to eq 'prefix 90%'
    end

    it 'adds the correct annotation to the array' do
      expect(subject[1]).to eq '90%'
    end

    context 'when value is a number' do
      it 'it returns an array with the value' do
        expect(subject.first).to eq 90
      end
    end

    context 'when value contains >' do
      subject { test_scores_bar_chart.array_for_single_bar('>90', 'prefix') }
      it 'it removes the > from the bar value' do
        expect(subject.first).to eq 90
      end
      it 'it leaves the > in the bar annotation' do
        expect(subject[1]).to eq '>90%'
      end
      it 'it leaves the > in the tooltip' do
        expect(subject[2]).to eq 'prefix >90%'
      end
    end

    context 'when value is nil' do
      subject { test_scores_bar_chart.array_for_single_bar(nil, 'prefix') }
      it 'it returns an array where value is zero' do
        expect(subject.first).to eq 0
      end
    end

    context 'when value is 90.9' do
      subject { test_scores_bar_chart.array_for_single_bar(90.9, 'prefix') }
      it 'rounds the value up to 91' do
        expect(subject).to eq [91, '91%', 'prefix 91%']
      end
    end
  end

end
require 'spec_helper'

describe BarChartBar do

  subject {BarChartBar}
  let(:base_config) {
    {
      label: 'Label',
      comparison_value: 25.62,
      perfomance_level: 'above_average'
    }
  }
  let(:zero_value_config) { base_config.merge( value: 0 )}
  let(:value_config) { base_config.merge( value: 40.40 )}
  let(:hundred_value_config) { base_config.merge( value: 100 )}
  let(:over_hundred_value_config) { base_config.merge( value: 109 )}
  let(:comparisonless_config) { base_config.merge( comparison_value: nil )}

  # write spec about no value
  # write spec about value = 0. gray should be 100 here
  # write spec about value = 100: gray whould be 0
  describe '#set_value_fields!' do
    {
      base_config: [nil, 100],
      zero_value_config: [0, 100],
      value_config: [40.40, 59.50],
      hundred_value_config: [100, 0],
      over_hundred_value_config: [100, 0],
    }.each do |config, values|
      context "with #{config}" do
        let!(:chart) { subject.new(eval(config.to_s)) }
        value, grey_value = values

        before do
          chart.send(:set_value_fields!)
        end

        if value
          it "should have value #{value}" do
            expect(chart.value).to eq(value.to_f.round)
          end

          it 'should have a rounded value' do
            expect(chart.value.round).to eq(chart.value)
          end

          it 'should not have a value > 100' do
            expect(chart.value).to be <= 100
          end
        end

        it "should have grey_value #{grey_value}" do
          expect(chart.grey_value).to eq(grey_value)
        end
      end
    end
  end

  describe '#display?' do
    {
      base_config: false,
      zero_value_config: true,
      value_config: true,
      hundred_value_config: true,
    }.each do |config, return_value|
      context "with #{config}" do
        let(:chart) { subject.new(eval(config.to_s)) }
        it "should be #{return_value}" do
          expect(chart.display?).to be return_value
        end
      end
    end
  end

  describe '#parse_config!' do
    context 'with a comparison value' do
      let(:chart) { subject.new(base_config) }

      it 'should round the comparison value' do
        chart.send(:parse_config!)
        expect(chart.comparison_value).to eq(base_config[:comparison_value].round)
      end
    end

    context 'without a comparison value' do
      let(:chart) { subject.new(comparisonless_config) }

      it 'should have no comparison value' do
        chart.send(:parse_config!)
        expect(chart.comparison_value).to be_nil
      end
    end
  end
end

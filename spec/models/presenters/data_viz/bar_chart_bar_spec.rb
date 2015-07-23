require 'spec_helper'

describe BarChartBar do

  subject {BarChartBar}
  let(:valueless_config) {
    {
      label: 'Label',
      comparison_value: 25.62,
      perfomance_level: 'above_average'
    }
  }
  let(:zero_value_config) { valueless_config.merge( value: 0 )}
  let(:value_config) { valueless_config.merge( value: 40.40 )}
  let(:hundred_value_config) { valueless_config.merge( value: 100 )}

  # write spec about no value
  # write spec about value = 0. gray should be 100 here
  # write spec about value = 100: gray whould be 0
  context '#set_value_fields!' do
    {
      valueless_config: [nil, 100],
      zero_value_config: [0, 100],
      value_config: [40.40, 59.50],
      hundred_value_config: [100, 0],
    }.each do |config, values|
      context "with #{config}" do
        let!(:chart) { subject.new(eval(config.to_s)) }

        before do
          chart.send(:set_value_fields!)
          @value, @grey_value = values
        end

        if @value
          it "should have value #{@value}" do
            expect(chart.value).to eq(@value.to_f.round)
          end

          it 'should have a rounded value' do
            expect(chart.value.round).to eq(chart.value)
          end
        end

        it "should have grey_value #{@grey_value}" do
          expect(chart.grey_value).to eq(@grey_value)
        end
      end
    end
  end

  context '#display?' do
    {
      valueless_config: false,
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
end

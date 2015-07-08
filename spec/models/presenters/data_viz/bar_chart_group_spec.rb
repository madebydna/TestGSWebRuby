require 'spec_helper'

describe BarChartGroup do

  let(:valid_data_point) {
    {
      year: 2013,
      source: "CA Dept. of Education",
      breakdown: "Pacific Islander",
      school_value: 100.0,
      state_average: 78.35,
      created: "2014-11-13T12:51:44-08:00",
      performance_level: "above_average"
    }
  }
  let(:valueless_data_point) { valid_data_point.merge(school_value: nil) }
  let(:state_averageless_data_point) { valid_data_point.merge(state_average: nil) }
  let(:earlier_data_point) { valid_data_point.merge(year: 2012) }
  context '#create_bar_charts!' do
    {
      valid_data_point: 1,
      valueless_data_point: 0,
      state_averageless_data_point: 1,
    }.each do |data_point, number_bar_charts|
      context "with a #{data_point}" do
        subject do
          # The array of bar charts
          BarChartGroup
            .new([eval(data_point.to_s)], nil, label_field: :breakdown)
            .send(:create_bar_charts!)
        end
        it "should create #{number_bar_charts} bar charts" do
          expect(subject.size).to eq(number_bar_charts)
        end
      end
    end

    context 'with something to group by' do
      subject do
        # The array of bar charts
        BarChartGroup
          .new([earlier_data_point, valid_data_point], nil, label_field: :year)
          .send(:create_bar_charts!)
      end
      it 'should create a bar chart for each group' do
        expect(subject.size).to eq(2)
        expect(subject.map(&:label).uniq).to eq([2013, 2012])
      end
    end
  end
end

require 'spec_helper'

describe BarChartGroupCollection do
  let(:data) {
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
  context '#create_bar_chart_groups!' do
    let(:data_points) { [data, data.merge(year: 2014), data.merge(year: 2019)] }
    context 'with a group_by year option specified' do
      subject do
        # The array of bar chart groups
        BarChartGroupCollection
          .new(nil, data_points, create_groups_by: :year)
          .send(:create_bar_chart_groups!)
      end

      it 'should create bar chart groups for each year' do
        expect(subject.map(&:title).uniq).to eq([2013, 2014, 2019])
      end

      it 'should create a bar chart group for each data point' do
        expect(subject.size).to eq(data_points.size)
      end
    end

    context 'with no group_by option specified' do
      subject do
        # The array of bar chart groups
        BarChartGroupCollection
          .new(nil, data_points)
          .send(:create_bar_chart_groups!)
      end

      it 'should create a single bar chart group' do
        expect(subject.size).to eq(1)
      end
    end
  end
end

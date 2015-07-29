require 'spec_helper'

describe BarChartCollection do
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

  describe '#create_bar_charts!' do
    let(:data_points) {
      [
        data.merge(breakdown: "Pacific Islander", school_value: 100.0, percent_of_population: 40, subtext: '40% of population'),
        data.merge(breakdown: "All Students", school_value: 100.0, percent_of_population: 10, subtext: '10% of population'),
        data.merge(breakdown: "Asian", school_value: 30.0, percent_of_population: 20, subtext: '20% of population'),
        data.merge(breakdown: "African American", school_value: 80.0, percent_of_population: 5, subtext: '5% of population' ),
        data.merge(breakdown: "European", school_value: 70.0, percent_of_population: 10, subtext: '10% of population'),
        data.merge(breakdown: "male", school_value: 40.0, percent_of_population: 15, subtext: '15% of population'),
        data.merge(breakdown: "female", school_value: 50.0, subtext: 'No data')
      ]
    }
    context 'when the group by gender callback is set' do
      subject do
        # The array of bar chart groups
        BarChartCollection
          .new(nil, data_points, create_groups_by: :breakdown, group_groups_by: [:gender], default_group: 'ethnicity')
          .send(:create_bar_charts!)
      end
      it 'should group the data by gender and everything else' do
        expect(subject.map(&:title)).to eq(['ethnicity', 'gender'])
      end
    end

    context 'when the sort by descending by percent breakdown and all students callbacks are set' do
      subject do
        # The array of bar chart groups
        BarChartCollection.new(nil, data_points, {
                    create_sort_by: :percent_of_population,
                    sort_groups_by: [:desc, :all_students],
                    default_group: 'ethnicity',
                    label_charts_with: :breakdown
        }).send(:create_bar_charts!)
      end
      it 'should sort the groups by percent breakdown descending and all students' do
        bar_chart_bars = subject.first.bar_chart_bars
        subtexts = bar_chart_bars.map do |bars|
          bars.subtext
        end
        parsed_subtext = subtexts[1..-1].sort_by do |subtext|
          parsed_string = /^\d+/.match(subtext)
          parsed_string.nil? ? -1 : parsed_string[0].to_i
        end.reverse!
        expect(subtexts[1..-1]).to eq(parsed_subtext)
        #leave out All students thats at the top and make sure the rest are in order

        all_students_label = bar_chart_bars.first.label
        expect(all_students_label).to eq('All Students')

      end
    end
  end




end

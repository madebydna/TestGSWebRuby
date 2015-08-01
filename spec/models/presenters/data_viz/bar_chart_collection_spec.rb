require 'spec_helper'

shared_example 'should group the data by gender and everything else' do
  expect(subject.bar_charts.map(&:title)).to eq(['ethnicity', 'gender'])
end

shared_example 'should duplicate the all students data point to all groups' do
  subject.data.values.each do | data_points |
    all_students_present = data_points.any? { |dp| dp[:breakdown].downcase == 'all students' }
    expect(all_students_present).to be_truthy
  end
end

shared_example 'should sort the groups by percent breakdown descending and all students' do
  bar_chart_bars = subject.bar_charts.first.bar_chart_bars
  subtexts = bar_chart_bars.map(&:subtext)
  parsed_subtext = subtexts[1..-1].sort_by do |subtext|
    parsed_string = /^\d+/.match(subtext)
    parsed_string.nil? ? -1 : parsed_string[0].to_i
  end.reverse!
  expect(subtexts[1..-1]).to eq(parsed_subtext)
  #leave out All students thats at the top and make sure the rest are in order

  all_students_label = bar_chart_bars.first.label
  expect(all_students_label).to eq('All Students')
end

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
        BarChartCollection.new(nil, data_points, {
          bar_chart_collection_callbacks: ['copy_all_students'],
          group_by: {'gender' => 'breakdown'},
          default_group: 'ethnicity'
        }.with_indifferent_access)
      end

      include_example 'should group the data by gender and everything else'

      context 'when the copy_all_students callback is set' do
        include_example 'should duplicate the all students data point to all groups'
      end
    end

    context 'when the sort by descending by percent breakdown and all students callbacks are set' do
      subject do
        # The array of bar chart groups
        BarChartCollection.new(nil, data_points, {
          bar_chart_callbacks: ['move_all_students'],
          sort_by: {'desc' => 'percent_of_population'},
          default_group: 'ethnicity',
          label_charts_with: 'breakdown'
        }.with_indifferent_access)
      end
      include_example 'should sort the groups by percent breakdown descending and all students'
    end

    #test with all configs set
    context 'when multiple config keys are set including' do
      config = {
        bar_chart_collection_callbacks: ['copy_all_students'],
        group_by: {'gender' => 'breakdown'},
        default_group: 'ethnicity',
        bar_chart_callbacks: ['move_all_students'],
        sort_by: {'desc' => 'percent_of_population'},
        label_charts_with: 'breakdown',
        breakdown: 'Ethnicity',
        breakdown_all: 'Enrollment'
      }.with_indifferent_access
      context "#{config}" do
        subject do
          BarChartCollection.new(nil, data_points, config)
        end

        include_example 'should group the data by gender and everything else'
        include_example 'should duplicate the all students data point to all groups'
        include_example 'should sort the groups by percent breakdown descending and all students'
      end
    end
  end
end

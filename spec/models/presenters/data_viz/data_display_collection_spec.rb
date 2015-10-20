require 'spec_helper'

def data_display_order
  ['ethnicity', 'program', 'gender']
end
shared_example 'should group the data by the appropriate groups' do |breakdowns|
  available_breakdowns = ['ethnicity'] + [*breakdowns]
  sorted_breakdowns = data_display_order
  expected_breakdowns = sorted_breakdowns & available_breakdowns
  expect(subject.displays.map(&:title)).to eq(expected_breakdowns)
end

shared_example 'should duplicate the all students data point to all groups' do
  subject.data.values.each do | data_points |
    all_students_present = data_points.any? { |dp| dp[:breakdown].downcase == 'all students' }
    expect(all_students_present).to be_truthy
  end
end

shared_example 'should sort the groups by percent breakdown descending and all students' do
  data_points = subject.displays.first.data_points
  subtexts = data_points.map(&:subtext)
  parsed_subtext = subtexts[1..-1].sort_by do |subtext|
    parsed_string = /^\d+/.match(subtext)
    parsed_string.nil? ? -1 : parsed_string[0].to_i
  end.reverse!
  expect(subtexts[1..-1]).to eq(parsed_subtext)
  #leave out All students thats at the top and make sure the rest are in order

  all_students_label = data_points.first.label
  expect(all_students_label).to eq('All Students')
end

describe DataDisplayCollection do
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

  describe '#create_displays!' do
    let(:data_points) {
      [
        data.merge(breakdown: "Pacific Islander", school_value: 100.0, percent_of_population: 40, subtext: '40% of population'),
        data.merge(breakdown: "All Students", school_value: 100.0, percent_of_population: 10, subtext: '10% of population'),
        data.merge(breakdown: "Asian", school_value: 30.0, percent_of_population: 20, subtext: '20% of population'),
        data.merge(breakdown: "African American", school_value: 80.0, percent_of_population: 5, subtext: '5% of population' ),
        data.merge(breakdown: "European", school_value: 70.0, percent_of_population: 24.85, subtext: '24% of population'),
        data.merge(breakdown: "male", school_value: 40.0, percent_of_population: 0.15, subtext: '<1% of population'),
        data.merge(breakdown: "female", school_value: 50.0, subtext: 'No data'),
        data.merge(breakdown: 'Economically disadvantaged', school_value: 40.0, percent_of_population: 0.15, subtext: '<1% of population'),
      ]
    }
    context 'when the group by gender callback is set' do
      subject do
        # The array of bar chart groups
        DataDisplayCollection.new(nil, data_points, {
          collection_callbacks: ['copy_all_students', 'order_data_displays'],
          group_by: {'gender' => 'breakdown'},
          default_group: 'ethnicity'
        }.with_indifferent_access)
      end

      include_example 'should group the data by the appropriate groups', 'gender'

      context 'when the copy_all_students callback is set' do
        include_example 'should duplicate the all students data point to all groups'
      end
    end

    context 'when the group by program callback is set' do
      subject do
        DataDisplayCollection.new(nil, data_points, {
          collection_callbacks: ['copy_all_students', 'order_data_displays'],
          group_by: {'program' => 'breakdown'},
          default_group: 'ethnicity'
        }.with_indifferent_access)
      end

      include_example 'should group the data by the appropriate groups', 'program'

      context 'when the copy_all_students callback is set' do
        include_example 'should duplicate the all students data point to all groups'
      end
    end

    context 'when the sort by descending by percent breakdown and all students callbacks are set' do
      subject do
        DataDisplayCollection.new(nil, data_points, {
          data_display_callbacks: ['move_all_students'],
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
        collection_callbacks: ['copy_all_students', 'order_data_displays'],
        group_by: {'gender' => 'breakdown', 'program' => 'breakdown'},
        default_group: 'ethnicity',
        data_display_callbacks: ['move_all_students'],
        data_display_order: data_display_order,
        sort_by: {'desc' => 'percent_of_population'},
        label_charts_with: 'breakdown',
        breakdown: 'Ethnicity',
        breakdown_all: 'Enrollment'
      }.with_indifferent_access
      context "#{config}" do
        subject do
          DataDisplayCollection.new(nil, data_points, config)
        end

        include_example 'should group the data by the appropriate groups', ['gender', 'program']
        include_example 'should duplicate the all students data point to all groups'
        include_example 'should sort the groups by percent breakdown descending and all students'
      end
    end
  end
end

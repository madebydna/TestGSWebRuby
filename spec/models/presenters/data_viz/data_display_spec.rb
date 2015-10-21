require 'spec_helper'

describe DataDisplay do

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
  context '#create_data_points!' do
    {
      valid_data_point: 1,
      valueless_data_point: 0,
      state_averageless_data_point: 1,
    }.each do |data_point, number_data_points|
      context "with a #{data_point}" do
        subject do
          # The array of data displays
          data_display = DataDisplay
            .new([eval(data_point.to_s)], nil, {'label_charts_with' => 'year'}.with_indifferent_access)
            .data_points
        end
        it "should create #{number_data_points} data displays" do
          expect(subject.size).to eq(number_data_points)
        end
      end
    end

    context 'with something to group by' do
      subject do
        DataDisplay
          .new([earlier_data_point, valid_data_point], nil, {'label_charts_with' => 'year'}.with_indifferent_access)
          .data_points
      end
      it 'should create a DataDisplay for each group' do
        expect(subject.size).to eq(2)
        expect(subject.map(&:label).uniq).to eq([2012, 2013])
      end
    end
  end
end

require 'spec_helper'

describe GroupComparisonDataReader do

  subject { GroupComparisonDataReader.new(nil) }

  let(:sample_data) {
    {
      first_data_type: [],
      second_data_type: [],
      third_data_type: []
    }
  }

  it 'should create a BarChartGroupCollection for each data type' do
    allow(subject).to receive(:cached_data_for_category).and_return(sample_data)
    expect(BarChartGroupCollection).to receive(:new).exactly(sample_data.keys.size).times
    subject.data_for_category(nil)
  end
end

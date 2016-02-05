require 'spec_helper'

describe GooglePieChartDataBuilder do
  context 'with valid data' do
    let(:valid_data) do
      {'Asian'=>58,
       'Hispanic'=>24,
       'Black'=>8,
       'Pacific Islander'=>3,
       'White'=>3,
       'Two or more races'=>2,
       'Filipino'=>2 }
    end

    let(:output) do
      [["Asian", 58, "<p>Asian 58%</p>"],
       ["Hispanic", 24, "<p>Hispanic 24%</p>"],
       ["Black", 8, "<p>Black 8%</p>"],
       ["Pacific Islander", 3, "<p>Pacific Islander 3%</p>"],
       ["White", 3, "<p>White 3%</p>"],
       ["Two or more races", 2, "<p>Two or more races 2%</p>"],
       ["Filipino", 2, "<p>Filipino 2%</p>"]]
    end

    it 'should return valid output' do
      expect(GooglePieChartDataBuilder.new(valid_data).build).to eq(output)
    end
  end
  context 'when initialized without a hash' do
    it 'should return empty array' do
      expect(GooglePieChartDataBuilder.new('dkfjdk').build).to eq([])
    end
  end

  context 'when initialized with invalid hash' do
# is invalid because a value is a string
    let(:invalid_data) do
      {'Asian'=>'58',
       'Hispanic'=>24,
       'Black'=>8,
       'Pacific Islander'=>3,
       'White'=>3,
       'Two or more races'=>2,
       'Filipino'=>2 }
    end
    it 'should return empty array' do
      expect(GooglePieChartDataBuilder.new(invalid_data).build).to eq([])
    end
    it 'should log an error' do
      expect(GSLogger).to receive(:error)
      GooglePieChartDataBuilder.new(invalid_data).build
    end
  end
end


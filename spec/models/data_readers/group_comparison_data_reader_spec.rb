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

  describe '#get_data' do
    context 'when config has {breakdown: \'Ethnicity\', breakdown_all: \'Enrollment\'} set' do
      let(:config) { { breakdown: 'Ethnicity', breakdown_all: 'Enrollment' } }
      let(:school) { FactoryGirl.create(:school, id: 1) }
      let!(:cachified_school) { FactoryGirl.create(:school_characteristic_responses, school_id: school.id, state: school.state ) }
      let(:fake_category) do
        o = Object.new
        allow(o).to receive(:keys).and_return(['Graduation Rate'])
        o
      end

      subject { GroupComparisonDataReader.new(school) }

      after { clean_models :gs_schooldb, SchoolCache }
      after { clean_models :ca, School }

      it 'should return results with the subtext key set' do
        data = subject.get_data(fake_category, config)
        data.values.first.each do |d|
          expect(d[:subtext]).to_not be_nil
        end
      end

      context 'when there is corresponding Ethnicity data for an ethnic data set' do
        it 'should set subtext to \'x% of population\'' do
          data = subject.get_data(fake_category, config)
          data.values.first.each do |d|
            (expect(d[:subtext]).to include '% of population') unless d[:breakdown] == 'All students'
          end
        end
      end

      context 'when there is corresponding Enrollment data for a ethnic data set' do
        it 'should set subtext to \'number students tested\'' do
          data = subject.get_data(fake_category, config)
          data.values.first.each do |d|
            (expect(d[:subtext]).to include 'students tested') if d[:breakdown] == 'All students'
          end
        end
      end

    end
  end
  
end

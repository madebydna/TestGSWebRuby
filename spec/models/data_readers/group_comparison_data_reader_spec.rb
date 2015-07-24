require 'spec_helper'

describe GroupComparisonDataReader do

  subject { GroupComparisonDataReader.new(nil) }

  let(:sample_data) {
    {
      first_data_type: [
        {
          year: 2013,
          breakdown: 'Pacific Islander different than ethnicity label',
          original_breakdown: 'Original breakdown',
          school_value: 100.0,
          state_average: 78.35,
          performance_level: 'above_average',
        }
      ],
      second_data_type: [
        {
          year: 2013,
          breakdown: 'Male',
          original_breakdown: 'Male',
          school_value: 90.0,
          state_average: 98.35,
          performance_level: 'average',
        }
      ],
      third_data_type: [
        {
          year: 2013,
          breakdown: 'Economically disadvantaged',
          original_breakdown: 'Economically disadvantaged',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
    }
  }

  let(:subtext_data) {
    {
      Ethnicity: [
        {
          year: 2013,
          breakdown: 'Pacific Islander',
          original_breakdown: 'Original breakdown',
          school_value: 100.0,
          state_average: 78.35,
          performance_level: 'above_average',
        },
      ],
      Male: [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 90.0,
          state_average: 98.35,
          performance_level: 'average',
        }
      ],
      'Economically disadvantaged'.to_sym => [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
      Enrollment: [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
    }
  }

  let(:sample_label_map) { Hash[sample_data.map { |k,v| [k.to_s,"#{k} label"] }] }
  let(:fake_category) do
    o = Object.new
    allow(o).to receive(:keys).and_return(sample_data.keys)
    allow(o).to receive(:key_label_map).and_return(sample_label_map)
    o
  end

  it 'should create a BarChartCollection for each data type' do
    allow(subject).to receive(:cached_data_for_category).and_return(sample_data)
    expect(BarChartCollection).to receive(:new).exactly(sample_data.keys.size).times
    subject.data_for_category(fake_category)
  end

  describe '#get_data!' do
    context 'when config has {breakdown: \'Ethnicity\', breakdown_all: \'Enrollment\'} set' do
      before do
        allow(subject).to receive(:cached_data_for_category).and_return(sample_data)
        allow(subject).to receive(:get_cache_data).and_return(subtext_data)
        allow(subject).to receive(:category).and_return(fake_category)
        allow(subject).to receive(:config).and_return({ breakdown: 'Ethnicity', breakdown_all: 'Enrollment' })
        subject.send(:get_data!)
      end

      let(:school) { FactoryGirl.create(:school, id: 1) }

      subject { GroupComparisonDataReader.new(school) }

      after { clean_models :gs_schooldb, SchoolCache }
      after { clean_models :ca, School }

      it 'should return results with the subtext key set' do
        subject.data.values.first.each do |d|
          expect(d[:subtext]).to_not be_nil
        end
      end

      it 'should put the labels of the data types as the data keys' do
        subject.data.keys.each do |key|
          expect(key).to match(/ label/)
        end
      end

      context 'when there is corresponding Ethnicity, gender, or programs data for a data set' do
        it 'should set subtext to \'x% of population\'' do
          subject.data.values.first.each do |d|
            (expect(d[:subtext]).to include '% of population') unless d[:breakdown] == 'All students'
          end
        end
      end

      context 'when there is corresponding Enrollment data for a data set' do
        it 'should set subtext to \'number students tested\'' do
          subject.data.values.first.each do |d|
            (expect(d[:subtext]).to include 'students tested') if d[:breakdown] == 'All students'
          end
        end
      end
    end
  end

end

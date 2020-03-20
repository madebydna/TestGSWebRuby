require 'spec_helper'

describe MetricsCaching::MetricsResults do

  describe 'behaves like an enumerable' do
    let(:results) { [
      instance_double(Omni::Metric),
      instance_double(Omni::Metric),
      instance_double(Omni::Metric)
      ]
    }

    subject { MetricsCaching::MetricsResults.new(results) }

    it "responds to #each and iterates over results" do
      expect(subject).to respond_to(:each)
    end

    it "responds to size" do
      expect(subject.size).to eq(3)
    end

    it "and wraps metrics with a MetricsDecorator" do
      subject.each do |metric|
        expect(metric).to be_a(MetricDecorator)
      end
    end
  end


  describe '#filter_to_max_year_per_data_type!' do
    let(:results) do
      [
        instance_double(Omni::Metric, value: 100, data_set: double(data_type_id: 1, date_valid: Date.civil(2020, 1, 5))),
        instance_double(Omni::Metric, value: 100, data_set: double(data_type_id: 1, date_valid: Date.civil(2019, 3, 17))),
        instance_double(Omni::Metric, value: 'x', data_set: double(data_type_id: 2, date_valid: Date.civil(2016, 2, 5))),
        instance_double(Omni::Metric, value: nil, data_set: double(data_type_id: 2, date_valid: Date.civil(2018, 10, 5)))
      ]
    end

    let(:all_data_type_ids) { subject.map(&:data_type_id).uniq }

    subject { MetricsCaching::MetricsResults.new(results) }


    before do
      subject.filter_to_max_year_per_data_type!
    end

    it 'retains all unique data_types for which there is at least one with a school value' do
      expect(all_data_type_ids.size).to eq(2)
      expect(all_data_type_ids).to include(1)
      expect(all_data_type_ids).to include(2)
    end

    it 'discards years for which there is no school value' do
      dt_2_data = subject.select {|x| x.data_type_id == 2 }
      expect(dt_2_data.length).to eq(1)
      expect(dt_2_data.first.year).to eq(2016)
    end

    it 'only retains max year by data type' do
      expected = subject.select {|m| m.data_type_id == 1}
      expect(expected.size).to eq(1)
      expect(expected.first.year).to eq(2020)
    end
  end

  describe '#sort_school_value_desc_by_data_type!' do
    let(:results) do
      [
        instance_double(Omni::Metric, value: 100, data_set: double(data_type_id: 1, date_valid: Date.civil(2020, 1, 5))),
        instance_double(Omni::Metric, value: 80, data_set: double(data_type_id: 1, date_valid: Date.civil(2020, 1, 5))),
        instance_double(Omni::Metric, value: 200, data_set: double(data_type_id: 1, date_valid: Date.civil(2019, 3, 17))),
        instance_double(Omni::Metric, value: nil, data_set: double(data_type_id: 2, date_valid: Date.civil(2016, 2, 5))),
        instance_double(Omni::Metric, value: 1, data_set: double(data_type_id: 2, date_valid: Date.civil(2018, 10, 5)))
      ]
    end

    subject { MetricsCaching::MetricsResults.new(results) }

    before do
      subject.sort_school_value_desc_by_data_type!
    end


    it 'sorts school values by data type in descending order' do
      dt_1_data = subject.select {|x| x.data_type_id == 1 }
      expect(dt_1_data[0].value).to eq(200)
      expect(dt_1_data[1].value).to eq(100)
      expect(dt_1_data[2].value).to eq(80)
    end

    it 'treats nil values as 0 when sorting' do
      dt_2_data = subject.select {|x| x.data_type_id == 2 }
      expect(dt_2_data[0].value).to eq(1)
      expect(dt_2_data[1].value).to eq(nil)
    end
  end


end
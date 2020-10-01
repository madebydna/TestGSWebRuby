require 'spec_helper'

describe 'DistrictCacheDataReader' do
  let(:district_record) { double("district record", state: "ca", district_id: 1) }

  subject { DistrictCacheDataReader.new(district_record) }

  describe '#decorate_district' do
    let(:district_cache_query) { double }

    before do
      allow(district_cache_query).to receive(:each).and_yield(OpenStruct.new({
        district_id: 1,
        state: 'ca',
        name: 'metrics',
        value: {}.to_json
      }))
      allow(subject).to receive(:district_cache_query).and_return(district_cache_query)
    end

    it 'returns a DistrictCacheDecorator instance' do
      expect(subject.decorate_district).to be_a(DistrictCacheDecorator)
    end

    it 'invokes DistrictCacheResults\' decorate_district method to decorate district' do
      dcr = double("DistrictCacheResults", decorate_district: nil)

      expect(DistrictCacheResults).to receive(:new).
        with(DistrictCacheDataReader::DISTRICT_CACHE_KEYS, district_cache_query).
        and_return(dcr)
      expect(dcr).to receive(:decorate_district).with(district_record)
      subject.decorate_district
    end
  end

  describe 'decorated_district and metrics cache' do
    let(:metrics_data) do
      {
        '4-year high school district graduation rate' => [
          MetricsCaching::Value.from_hash({
            "breakdown" => "All students",
            "district_value" => 68,
            "source" => "CA Department of Education"
          }),
          MetricsCaching::Value.from_hash({
            "breakdown" => "Hispanic",
            "district_value" => 64,
            "source" => "CA Department of Education"
          })
        ].extend(MetricsCaching::Value::CollectionMethods),
        "Percentage of students enrolled in IB grades 9-12" => [
          MetricsCaching::Value.from_hash({
            "breakdown" => "Native American",
            "district_value" => 19.047619,
            "source" => "Civil Rights Data Collection",
          }),
          MetricsCaching::Value.from_hash({
            "breakdown" => "Asian",
            "district_value" => 22.434368,
            "source" => "Civil Rights Data Collection",
          })
        ].extend(MetricsCaching::Value::CollectionMethods)
      }
    end

    let(:decorated_district) do
      double("decorated district",
        district: district_record,
        cache_data: {},
        decorated_metrics: metrics_data,
        ethnicity_data: [
          {
            "breakdown" => "Hispanic",
            "district_value" => 39
          }
        ]
      )
    end

    before do
      allow(subject).to receive(:decorated_district).and_return(decorated_district)
    end

    it "#decorated_metrics_data selects decorated district's metrics data for given single key" do
      expect(decorated_district).to receive(:decorated_metrics)
      results = subject.decorated_metrics_data('4-year high school district graduation rate')
      expect(results.length).to eq(2)
      expect(results[0].breakdown).to eq("All students")
      expect(results[1].breakdown).to eq("Hispanic")
    end

    it "#decorated_metrics_datas selects decorated district's metrics data for multiple keys" do
      expect(decorated_district).to receive(:decorated_metrics)
      results = subject.decorated_metrics_datas('4-year high school district graduation rate', 'Percentage of students enrolled in IB grades 9-12')
      expect(results).to have_key('4-year high school district graduation rate')
      expect(results).to have_key('Percentage of students enrolled in IB grades 9-12')
      expect(results['4-year high school district graduation rate'].length).to eq(2)
      expect(results['Percentage of students enrolled in IB grades 9-12'].length).to eq(2)
    end

    it '#ethnicity_data invokes equally named method on decorated district' do
      expect(decorated_district).to receive(:ethnicity_data)
      expect(subject.ethnicity_data).to eq(
        [
          {
            "breakdown" => "Hispanic",
            "district_value" => 39
          }
        ]
      )
    end
  end

end
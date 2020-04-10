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
          {
            "breakdown" => "All students",
            "district_value" => 68,
            "source" => "CA Department of Education"
          },
          {
            "breakdown" => "Hispanic",
            "district_value" => 64
          }
        ]
      }
    end

    let(:decorated_district) do
      double("decorated district",
        district: district_record,
        cache_data: {},
        metrics: metrics_data,
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

    it "#metrics_data selects decorated district's metrics data points with a source" do
      expect(decorated_district).to receive(:metrics)
      expect(subject.metrics_data('4-year high school district graduation rate')).to eq(
        { "4-year high school district graduation rate" =>
          [ {
            "breakdown" => "All students",
            "district_value" => 68,
            "source" => "CA Department of Education"
            } ]
        }
      )
    end

    it '#metrics and returns entire metrics hash via decorated districs' do
      expect(decorated_district).to receive(:metrics)
      expect(subject.metrics).to eq(metrics_data)
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
require 'spec_helper'

describe CachedMetricsMethods do
  class DummyClass
    attr_accessor :cache_data
    # needed for number_with_delimiter
    include ActionView::Helpers::NumberHelper
    include CachedMetricsMethods
  end

  subject { DummyClass.new }

  describe '#metrics' do
    before do
      subject.cache_data = { "metrics" => {foo: 1} }
    end

    it 'should return contents of metrics key from cache' do
      expect(subject.metrics).to eq({foo: 1})
    end
  end

  let(:enrollment_data) do
    {
      "Enrollment" => [
        {
          "breakdown" => "All students",
          "created" => "2020-02-11T16:42:26-08:00",
          "grade" => "All",
          "school_value" => 1767
        },
        {
          "breakdown" => "All students",
          "created" => "2020-02-11T16:42:26-08:00",
          "grade" => "9",
          "school_value" => 465
        }
      ]
    }
  end

  describe '#students_enrolled' do
    before do
      subject.cache_data = { "metrics" => enrollment_data }
    end

    it 'returns the formatted school_value for the Enrollment entry for all grades' do
      expect(subject.students_enrolled).to eq('1,767')
    end
  end

  describe '#numeric_enrollment' do
    before do
      subject.cache_data = { "metrics" => enrollment_data }
    end

    it 'returns the formatted school_value for the Enrollment entry for all grades' do
      expect(subject.numeric_enrollment).to eq(1767)
    end
  end

  describe '#created_time' do
    before do
      subject.cache_data = { "metrics" => enrollment_data }
    end

    it 'returns a Time object with the first created time for a valid key' do
      expect(subject.created_time('Enrollment')).to eq(Time.parse "2020-02-11T16:42:26-08:00")
    end

    it 'returns nil for invalid key' do
      expect(subject.created_time('Invalid')).to be_nil
    end
  end

  describe 'school leader methods' do
    let(:leader_data) do
      {
        "Head official email address" => [
          {
            "grade" => "NA",
            "school_value" => "rithurburn@alameda.k12.ca.us",
          }
        ],
        "Head official name" => [
          {
            "grade" => "NA",
            "school_value" => "Robert Ithurburn",
          }
        ],
      }
    end

    before { subject.cache_data = { "metrics" => leader_data } }

    it '#school_leader returns head official name' do
      expect(subject.school_leader).to eq("Robert Ithurburn")
    end

    it '#school_leader_email returns head official email' do
      expect(subject.school_leader_email).to eq("rithurburn@alameda.k12.ca.us")
    end
  end

  describe '#enroll_in_college' do
    let(:college_enrollment_data) do
      {

      }
    end

  end
end
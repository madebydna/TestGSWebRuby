require 'spec_helper'

describe MetricDecorator do
  after { clean_dbs(:omni) }

  before do
    @data_type = create(:data_type, name: "Enrollment")
    source = create(:source, name: "CRDC")
    data_set = create(:data_set, data_type: @data_type, date_valid: Date.civil(2020,3,4), source: source)
    subject = create(:subject, id: 0, name: "Not Applicable")
    @breakdown = create(:breakdown, :with_tags, name: "African American", id: 2)
    @metric = create(:metric, data_set: data_set, subject: subject, breakdown: @breakdown)
  end

  subject { MetricDecorator.new(@metric) }

  its('data_type_id') { is_expected.to eq @data_type.id }
  its('year') { is_expected.to eq 2020 }
  its('source_date_valid') { is_expected.to eq '2020-03-04 00:00:00.000000000 -0800' }
  its('label') { is_expected.to eq "Enrollment" }
  its('source_name') { is_expected.to eq "CRDC" }
  its('subject_name') { is_expected.to eq "Not Applicable" }
  its('breakdown_name') { is_expected.to eq "African American" }
  its('breakdown_tags') { is_expected.to eq @breakdown.breakdown_tags.first.tag }
end
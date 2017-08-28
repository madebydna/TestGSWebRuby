require 'spec_helper'

describe SchoolProfiles::Equity do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:equity) do
    SchoolProfiles::Equity.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  describe '#sources_for_view' do
    before do
      allow(school_cache_data_reader).to receive(:characteristics).and_return([])
      allow(school_cache_data_reader).to receive(:test_scores).and_return({values: []})
      allow(school_cache_data_reader).to receive(:discipline_flag?).and_return(false)
      allow(school_cache_data_reader).to receive(:attendance_flag?).and_return(false)
    end
    subject { equity.sources_for_view(hash) }
    let(:hash) { valid_hash }
    let(:valid_hash) do
      {
        label: 'foo',
        description: 'description',
        source: 'foo',
        year: 2014
      }
    end

    it { is_expected.to be_a(String) }

    context 'with missing source' do
      let(:hash) { valid_hash.except(:source) }
      it { is_expected.to be_a(String) }
    end
    context 'with missing year' do
      let(:hash) { valid_hash.except(:year) }
      it { is_expected.to be_a(String) }
    end
  end

end

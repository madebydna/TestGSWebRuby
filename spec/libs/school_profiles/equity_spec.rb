require 'spec_helper'

describe SchoolProfiles::Equity do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:equity) do
    SchoolProfiles::Equity.new(
      school_cache_data_reader: school_cache_data_reader,
      test_source_data: nil
    )
  end
  before do
    allow(school_cache_data_reader).to receive(:metrics).and_return([])
    allow(school_cache_data_reader).to receive(:test_scores).and_return({values: []})
    allow(school_cache_data_reader).to receive(:discipline_flag?).and_return(false)
    allow(school_cache_data_reader).to receive(:attendance_flag?).and_return(false)
  end

  describe '#sources_for_view' do
    subject { equity.sources_text(hash) }
    let(:hash) { OpenStruct.new(valid_hash) }
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

  describe '#discipline_attendance_flag_sources' do
    subject { equity.discipline_attendance_flag_sources }

    context 'with no data' do
      before { allow(school_cache_data_reader).to receive(:discipline_attendance_data_values).and_return({}) }

      it { is_expected.to be_empty }
    end

    context 'with one flag' do
      let (:hash) do
        {
            'Discipline Flag' => OpenStruct.new(description: 'The Discipline & Attendance Flags are where it\'s at',
                                                source_name: 'GreatSchools',
                                                source_year: '2017'
            )
        }
      end
      before do
        allow(school_cache_data_reader).to receive(:discipline_attendance_data_values).and_return(hash)
        allow(equity).to receive(:static_label).with(:discipline_attendance_flag).and_return('GreatSchools discipline & attendance flags')
        allow(equity).to receive(:static_label).with('source').and_return('GreatSchools')
      end

      it { is_expected.to match('GreatSchools discipline & attendance flags')}
      it { is_expected.to match('GreatSchools, 2017')}
      it { is_expected.to match('The Discipline & Attendance Flags are where it\'s at')}
    end

    context 'with two flags' do
      let (:hash) do
        {
            'Discipline Flag' => OpenStruct.new(description: 'The Discipline & Attendance Flags are where it\'s at',
                                                source_name: 'GreatSchools',
                                                source_year: '2017'
            ),
            'Absence Flag' => OpenStruct.new(description: 'The Discipline & Attendance Flags are where it is at',
                                             source_name: 'GreatSchool',
                                             source_year: '2016'
            )
        }
      end
      before do
        allow(school_cache_data_reader).to receive(:discipline_attendance_data_values).and_return(hash)
        allow(equity).to receive(:static_label).with(:discipline_attendance_flag).and_return('GreatSchools discipline & attendance flags')
        allow(equity).to receive(:static_label).with('source').and_return('GreatSchools')
      end

      it { is_expected.to match('GreatSchools discipline & attendance flags')}
      it { is_expected.to match('GreatSchools, 2017')}
      it { is_expected.to match('The Discipline & Attendance Flags are where it\'s at')}
    end
  end
end

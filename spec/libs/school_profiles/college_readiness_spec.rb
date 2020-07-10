require "spec_helper"

describe 'SchoolProfiles::CollegeReadiness' do
  let(:school_cache_data_reader) { double('SchoolCacheDataReader') }
  let(:school) { create(:school)}
  subject { SchoolProfiles::CollegeReadiness.new(school_cache_data_reader: school_cache_data_reader) }

  after { clean_dbs :ca }

  describe '#sat_percent_college_ready_text_key' do
    it 'returns the right key when grade is All' do
      expect(subject.sat_percent_college_ready_text_key('All')).to eq("SAT percent college ready")
    end

    it 'returns the right key when grade is 11' do
      expect(subject.sat_percent_college_ready_text_key('11')).to eq("SAT percent college ready(11th Grade)")
    end

    it 'returns the right key when grade is 12' do
      expect(subject.sat_percent_college_ready_text_key('12')).to eq("SAT percent college ready(12th Grade)")
    end

    it 'raises an error when the grade isnt recognize by the config files' do
      allow(school_cache_data_reader).to receive(:school).and_return(school)
      %w(1 2 3 4 5 6 7 8 9 10).each do |grade|
        expect(subject.sat_percent_college_ready_text_key(grade)).to be_nil
      end
    end
  end
end
require 'spec_helper'

describe SchoolProfiles::Toc do
  ##will want to make a school that is missing some data
  let(:school) { double('school') }
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  let(:test_scores) {double('test_scores')}
  let(:college_readiness) {double('college_readiness')}
  let(:equity) {double('equity')}
  let(:students) {double('students')}

  subject(:toc) do
    SchoolProfiles::Toc.new(test_scores, college_readiness, equity, students)
  end

  it { is_expected.to respond_to(:content) }

  describe "#academics" do
    let(:academics) {
      { :academics => [
          { column: 'Academics', label: 'Test scores', present: true, rating: '3', anchor: 'Test_scores' },
          { column: 'Academics', label: 'College readiness', present: true, rating: '6', anchor: 'College_readiness' }
      ]
      }
    }
    it 'first test' do
      pending 'WIP'
      expect(subject.academics).to eq(Hash)
    end
  end

  describe "#equity" do
    it 'second test' do
      pending 'WIP'
      allow(subject).to receive(:equity) {
        { :equity => [
            { column: 'Equity', label: 'Low-income students', present: true, rating: '2', anchor: 'Low-income_students' },
            { column: 'Equity', label: 'Race/ethnicity', present: true, rating: nil, anchor: 'Race/ethnicity' }
        ]
        }
      }
      expect(subject.equity).to eq(Hash)
    end
  end

  describe "#environment" do

  end
end
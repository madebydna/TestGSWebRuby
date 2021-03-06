require 'spec_helper'

describe SchoolProfiles::Toc do
  ##will want to make a school that is missing some data
  let(:school) { double('school') }
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  let(:test_scores) {double('test_scores')}
  let(:student_progress) {double('student_progress')}
  let(:college_readiness) {double('college_readiness')}
  let(:equity_overview) {double('equity_overview')}
  let(:equity) {double('equity')}
  let(:students) {double('students')}
  let(:teacher_staff) {double('teacher_staff')}
  let(:courses) {double('courses')}
  let(:stem_courses) {double('stem_courses')}
  let(:academic_progress) {double('academic_progress')}
  let(:college_success) {double('college_success')}

  subject(:toc) do
    SchoolProfiles::Toc.new(test_scores: test_scores, college_readiness: college_readiness, student_progress: student_progress,
                            equity_overview: equity_overview, equity: equity, students: students, teachers_staff: teacher_staff,
                            courses: courses, stem_courses: stem_courses, academic_progress: academic_progress, school: school,
                            college_success: college_success)
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

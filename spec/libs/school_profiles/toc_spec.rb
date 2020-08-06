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
  let(:stem_courses) {double('stem_courses')}
  let(:academic_progress) {double('academic_progress')}
  let(:college_success) {double('college_success')}

  subject(:toc) do
    SchoolProfiles::Toc.new(test_scores: test_scores, college_readiness: college_readiness, student_progress: student_progress,
                            equity_overview: equity_overview, equity: equity, students: students, teachers_staff: teacher_staff,
                            stem_courses: stem_courses, academic_progress: academic_progress, school: school,
                            college_success: college_success)
  end

  it { is_expected.to respond_to(:content) }

  describe "#academics" do
    subject(:academics) { toc.academics[:academics] }
    before do
      allow(student_progress).to receive(:student_progress_state?).and_return(false)
      allow(academic_progress).to receive(:academic_progress_state?).and_return(false)
      allow(college_readiness).to receive(:rating).and_return(5)
      allow(college_success).to receive(:visible?).and_return(false)
      allow(test_scores).to receive(:visible?).and_return(false)
    end

    context 'with a high school' do
      before do
        allow(school).to receive(:level_code).and_return('h')
        allow(school).to receive(:includes_highschool?).and_return(true)
      end

      context 'with stem courses data' do
        before { allow(stem_courses).to receive(:visible?).and_return(true) }

        it { is_expected.to include({column: 'Academics', label: 'advanced_courses', present: true, rating: '', anchor: 'Advanced_courses'})}
      end

      context 'without stem courses data' do
        before { allow(stem_courses).to receive(:visible?).and_return(false) }

        it { is_expected.to_not include({column: 'Academics', label: 'advanced_courses', present: true, rating: '', anchor: 'Advanced_courses'})}
      end
    end

    context 'with a middle school' do
      before do
        allow(school).to receive(:level_code).and_return('m')
        allow(school).to receive(:includes_highschool?).and_return(false)
        allow(school).to receive(:includes_level_code?).with(%w(m h)).and_return(true)
      end

      context 'with stem courses data' do
        before { allow(stem_courses).to receive(:visible?).and_return(true) }

        it { is_expected.to include({column: 'Academics', label: 'advanced_courses', present: true, rating: '', anchor: 'Advanced_courses'})}
      end

      context 'without stem courses data' do
        before { allow(stem_courses).to receive(:visible?).and_return(false) }

        it { is_expected.to be_nil }
      end
    end
  end
end

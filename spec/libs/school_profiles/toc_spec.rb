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

      context 'with an Academic Progress state' do
        before do
          allow(academic_progress).to receive(:academic_progress_state?).and_return(true)
          allow(stem_courses).to receive(:visible?).and_return(false)
        end

        it 'return a module if it has a rating' do
          allow(academic_progress).to receive(:visible?).and_return(true)
          allow(academic_progress).to receive(:academic_progress_rating).and_return(7)

          expect(subject).to include({column: 'Academics', label: 'academic_progress', present: true, rating: 7, anchor: 'Academic_progress'})
        end
        
        it 'return a module if it has no rating but other high schools have one' do
          allow(academic_progress).to receive(:visible?).and_return(true)
          allow(academic_progress).to receive(:academic_progress_rating).and_return(nil)

          expect(subject).to include({column: 'Academics', label: 'academic_progress', present: true, rating: nil, anchor: 'Academic_progress'})
        end

        it 'does not return the module if the state doesnt have Academic Progress data' do
          allow(academic_progress).to receive(:academic_progress_state?).and_return(false)

          expect(subject).to_not include({column: 'Academics', label: 'academic_progress', present: true, rating: nil, anchor: 'Academic_progress'})
        end
      end

      context 'with an Student Progress state' do
        before do
          allow(student_progress).to receive(:student_progress_state?).and_return(true)
          allow(stem_courses).to receive(:visible?).and_return(false)
        end

        it 'return a module if it has a rating' do
          allow(student_progress).to receive(:visible?).and_return(true)
          allow(student_progress).to receive(:rating).and_return(7)

          expect(subject).to include({column: 'Academics', label: 'student_progress', present: true, rating: 7, anchor: 'Student_progress'})
        end
        
        it 'return a module if it has no rating but other high schools have one' do
          allow(student_progress).to receive(:visible?).and_return(true)
          allow(student_progress).to receive(:rating).and_return(nil)

          expect(subject).to include({column: 'Academics', label: 'student_progress', present: true, rating: nil, anchor: 'Student_progress'})
        end

        it 'does not return the module if the state doesnt have Student Progress data' do
          allow(student_progress).to receive(:student_progress_state?).and_return(false)

          expect(subject).to_not include({column: 'Academics', label: 'student_progress', present: true, rating: nil, anchor: 'Student_progress'})
        end
      end

      context 'College Readiness and College Success' do
        before do
          allow(college_success).to receive(:visible?).and_return(true)
          allow(college_readiness).to receive(:rating).and_return(5)
          allow(college_success).to receive(:school_csa_badge?).and_return(false)
          allow(stem_courses).to receive(:visible?).and_return(true)
        end

        it "should return the college readiness and college success tabs" do
          expect(subject).to include({column: 'Academics', label: 'college_readiness', present: true, rating: 5, anchor: 'College_readiness'})
          expect(subject).to include({column: 'Academics', label: 'college_success', present: true, anchor: 'College_success', badge: false})
        end

        it 'should only return college readiness if there is no college success data' do
          allow(college_success).to receive(:visible?).and_return(false)
          expect(subject).to include({column: 'Academics', label: 'college_readiness', present: true, rating: 5, anchor: 'College_readiness'})
          expect(subject).to_not include({column: 'Academics', label: 'college_success', present: true, anchor: 'College_success', badge: false})
        end
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

      context 'with an Academic Progress state' do
        before do
          allow(academic_progress).to receive(:academic_progress_state?).and_return(true)
          allow(stem_courses).to receive(:visible?).and_return(false)
        end

        it 'return a module if it has a rating' do
          allow(academic_progress).to receive(:visible?).and_return(true)
          allow(academic_progress).to receive(:academic_progress_rating).and_return(7)

          expect(subject).to include({column: 'Academics', label: 'academic_progress', present: true, rating: 7, anchor: 'Academic_progress'})
        end
        
        it 'return a module if it has no rating but other schools do' do
          allow(academic_progress).to receive(:visible?).and_return(true)
          allow(academic_progress).to receive(:academic_progress_rating).and_return(nil)

          expect(subject).to include({column: 'Academics', label: 'academic_progress', present: true, rating: nil, anchor: 'Academic_progress'})
        end
      end

      context 'with an Student Progress state' do
        before do
          allow(student_progress).to receive(:student_progress_state?).and_return(true)
          allow(stem_courses).to receive(:visible?).and_return(true)
        end

        it 'return a module if it has a rating' do
          allow(student_progress).to receive(:visible?).and_return(true)
          allow(student_progress).to receive(:rating).and_return(7)

          expect(subject).to include({column: 'Academics', label: 'student_progress', present: true, rating: 7, anchor: 'Student_progress'})
        end
        
        it 'return a module if it has no rating but other school do' do
          allow(student_progress).to receive(:visible?).and_return(true)
          allow(student_progress).to receive(:rating).and_return(nil)

          expect(subject).to include({column: 'Academics', label: 'student_progress', present: true, rating: nil, anchor: 'Student_progress'})
        end
      end
    end
  end
end

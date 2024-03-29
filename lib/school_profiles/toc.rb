module SchoolProfiles
  class Toc

    attr_reader :school

    attr_accessor :content

    DEEP_LINK_HASH_SEPARATOR = '*'

    def initialize(test_scores:, college_readiness:, college_success:, student_progress:, equity:, equity_overview:,
                   students:, teachers_staff:, courses:, stem_courses:, academic_progress:, school:)
      @test_scores = test_scores
      @college_readiness = college_readiness
      @college_success = college_success
      @student_progress = student_progress
      @equity = equity
      @equity_overview = equity_overview
      @students = students
      @teacher_staff = teachers_staff
      @courses = courses
      @stem_courses = stem_courses
      @academic_progress = academic_progress
      @school = school
    end

    def academics
      hash = {}
      arr = []
      if @school.level_code =~ /h/
        arr << {column: 'Academics', label: 'college_readiness', present: true, rating: @college_readiness.rating, anchor: 'College_readiness'}
        arr << {column: 'Academics', label: 'college_success', present: true, anchor: 'College_success', badge: @college_success.school_csa_badge?} if @college_success.visible?
      end

      arr << {column: 'Academics', label: 'test_scores', present: true, rating: @test_scores.rating, anchor: 'Test_scores'}

      # NOTE LOGIC FOR STUDENT PROGRESS (SP) vs. ACADEMIC PROGRESS (AP):
      # The SP module has a no-data state, while The AP module DOES NOT have a no-data state.
      # AP.visible? checks to see if the school has AP data AND if the school is (e,m)
      # SP.visible? checks to see if the school has SP data OR if the school is (e,m)
      # We only show the AP module if the school has data for AP AND the school is (e,m) AND the school DOES NOT have data for SP
      # Else, if the school is (e,m), we show SP, whether SP has data, or not (no-data state)
      if @academic_progress.visible? && !@student_progress.has_data?
        arr << {column: 'Academics', label: 'academic_progress', present: true, rating: @academic_progress.academic_progress_rating, anchor: 'Academic_progress'}
      elsif @student_progress.visible?
        arr << {column: 'Academics', label: 'student_progress', present: true, rating: @student_progress.rating, anchor: 'Student_progress'}
      end

      if @school.includes_level_code?(%w[m h]) || @courses.visible? || @stem_courses.visible?
        arr << {column: 'Academics', label: 'advanced_courses', present: true, rating: @courses.rating, anchor: 'Advanced_courses'}
      end
      hash[:academics] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def equity
      hash = {}
      arr = []
      if @equity_overview.has_rating?
        arr << {column: 'Equity', label: 'equity_overview', present: true, rating: @equity_overview.equity_rating, anchor: 'Equity_overview'}
      end
      arr << {column: 'Equity', label: 'race_ethnicity', present: true, rating: nil, anchor: 'Race_ethnicity'}
      arr << {column: 'Equity', label: 'low_income', present: true, rating: @equity.rating_low_income.to_f.round, anchor: 'Low-income_students'}
      arr << {column: 'Equity', label: 'disabilities', present: true, rating: nil, anchor: 'Students_with_Disabilities'}
      hash[:equity] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def environment
      hash = {}
      arr = []
      arr << {column: 'Environment', label: 'students', present: true, rating: nil, anchor: 'Students'}

      if @equity.race_ethnicity_discipline_and_attendance_visible?
        arr << {column: 'Environment', label: 'discipline_and_attendance', present: true, rating: nil,
                anchor: 'Race_ethnicity'+DEEP_LINK_HASH_SEPARATOR+'Discipline_and_attendance',
                flagged: @equity.discipline_attendance_flag? }
      end

      arr << {column: 'Environment', label: 'teachers_staff_html', present: true, rating: nil, anchor: 'Teachers_staff'}
      arr << {column: 'Environment', label: 'neighborhood', present: true, rating: nil, anchor: 'Neighborhood'}
      hash[:environment] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def content
      [academics, equity, environment].reject{ |hash| hash.all?(&:empty?) }
    end

    def info_text(key)
      key.to_sym
      I18n.t(key.to_sym, scope: 'lib.toc', default: key)
    end
  end
end

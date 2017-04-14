module SchoolProfiles
  class Toc

    attr_reader :school

    attr_accessor :content

    def initialize(test_scores, college_readiness, equity, students, teacher_staff, courses, school)
      @test_scores = test_scores
      @college_readiness = college_readiness
      @equity = equity
      @students = students
      @teacher_staff = teacher_staff
      @courses = courses
      @school = school
    end

    def academics
      hash = {}
      arr = []
      arr << {column: 'Academics', label: 'test_scores', present: true, rating: @test_scores.rating, anchor: 'Test_scores'}
      if @school.level_code =~ /h/
        arr << {column: 'Academics', label: 'college_readiness', present: true, rating: @college_readiness.rating, anchor: 'College_readiness'}
        arr << {column: 'Academics', label: 'advanced_courses', present: true, rating: @courses.rating, anchor: 'Advanced_courses'}
      end
      hash[:academics] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def equity
      hash = {}
      arr = []
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

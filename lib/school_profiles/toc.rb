module SchoolProfiles
  class Toc

    attr_reader :school

    attr_accessor :content

    def initialize(test_scores, college_readiness, equity, students)
      @test_scores = test_scores
      @college_readiness = college_readiness
      @equity = equity
      @students = students
    end

    def academics
      hash = {}
      arr = []
      if @test_scores.visible?
        arr << {column: 'Academics', label: 'Test scores', present: true, rating: @test_scores.rating, anchor: 'Test_scores'}
      end
      if @college_readiness.visible?
        arr << {column: 'Academics', label: 'College readiness', present: true, rating: @college_readiness.rating, anchor: 'College_readiness'}
      end
      hash[:academics] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def equity
      hash = {}
      arr = []
      if @equity.low_income_visible?
        arr << {column: 'Equity', label: 'Low-income students', present: true, rating: @equity.rating_low_income.to_f.round, anchor: 'Low-income_students'}
      end
      if @equity.ethnicity_visible?
        arr << {column: 'Equity', label: 'Race/ethnicity', present: true, rating: nil, anchor: 'Race/ethnicity'}
      end
      hash[:equity] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def environment
      hash = {}
      arr = []
      if @students.visible?
        arr << {column: 'Environment', label: 'Students', present: true, rating: nil, anchor: 'Students'}
      end
      arr << {column: 'Environment', label: 'Neighborhood', present: true, rating: nil, anchor: 'Neighborhood'}
      hash[:environment] = arr
      hash.delete_if{|key, value| value.blank?}
    end

    def content
      [academics, equity, environment].reject{ |hash| hash.all?(&:empty?) }
    end

  end
end

module SchoolProfiles
  class SummaryRating

    attr_reader :school

    # ALLOWED_RATINGS = {
    #   'Test Score Rating' => {rating_component: t('Test Scores'), weight: 'Summary Rating Weight: Test Score Rating' },
    #   'Student Progress Rating' => {rating_component: t('Student Progress'), weight: 'Summary Rating Weight: Student Progress Rating'},
    #   'Academic Progress Rating' => {rating_component: t('Academic Progress'), weight: 'Summary Rating Weight: Academic Progress Rating'},
    #   'College Readiness Rating' => {rating_component: t('College Readiness'), weight: 'Summary Rating Weight: College Readiness Rating'},
    #   'Advanced Course Rating' => {rating_component: t('Advanced Courses'), weight: 'Summary Rating Weight: Advanced Course Rating'},
    #   'Equity Rating' => {rating_component: t('Equity Overview'), weight: 'Summary Rating Weight: Equity Rating'},
    #   'Equity Adjustment Factor' => {rating_component: t('Equity adjustment factor'), weight: 'Summary Rating Weight: Equity Adjustment Factor'},
    #   'Discipline flag' => {rating_component: t('Discipline'), weight: 'Summary Rating Weight: Discipline Flag'},
    #   'Attendance flag' => {rating_component: t('Attendance'), weight: 'Summary Rating Weight: Absence Flag'}
    # }

    def initialize(test_scores, college_readiness, student_progress, equity_overview, courses, stem_courses, school)
      @test_scores = test_scores
      @student_progress = student_progress
      @college_readiness = college_readiness
      @equity_overview = equity_overview
      @courses = courses
      @stem_courses = stem_courses
      @school = school
    end

    def content
      @_content ||= build_content_for_summary_rating_table
    end

    def build_content_for_summary_rating_table
      rating_array = [test_scores, student_progress, college_readiness, equity, courses]
      rating_array.reject! {|row| row.empty?}
      rating_array.sort_by {|row| row[:weight]}.reverse
    end

    def test_scores
      test_score_hash = {}
      if @test_scores.visible?
        test_score_hash.merge({column: 'Test Scores', rating: @test_scores.rating, weight: 'stub', })
      end
      test_score_hash
    end

    def student_progress
      student_progress_hash = {}
      #should return either student or academic progress
    end

    def college_readiness
      college_readiness_hash = {}
      if @school.level_code =~ /h/
        college_readiness_hash.merge({column: 'College Readiness', rating: @college_readiness.rating, weight: 'stub'})
      end
      college_readiness_hash
    end

    def equity
      equity_hash = {}
      if @equity_overview.has_rating?
        equity_hash << {column: 'Equity Overview', rating: @equity_overview.equity_rating, weight: 'stub'}
      #else
        #TODO build equity adjustment reader and return that if there's a value
      end
    end

    def courses

    end

    def t(string)
      I18n.t(string, scope: 'lib.summary_rating', default: I18n.t(string, default: string))
    end

  end
end

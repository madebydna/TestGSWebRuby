module SchoolProfiles
  class SummaryRating

    attr_reader :school

    delegate :gs_rating, to: :school_cache_data_reader


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
    # ['Summary Rating Weight: Test Score Rating']

    def initialize(test_scores, college_readiness, student_progress, academic_progress, equity_overview, courses, stem_courses, school, school_cache_data_reader:)
      @test_scores = test_scores
      @student_progress = student_progress
      @academic_progress = academic_progress
      @college_readiness = college_readiness
      @equity_overview = equity_overview
      @courses = courses
      @stem_courses = stem_courses
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def content
      # each row is a hash in format: {title: Some Title, rating: 8, weight: .67}
      @_content ||= build_content_for_summary_rating_table
    end

    def build_content_for_summary_rating_table
      rating_array = [test_scores, student_progress, college_readiness, equity, courses, discipline, attendance]
      rating_array.reject! {|row| row.nil? || row.empty?}
      rating_array.sort_by {|row| row[:weight]}.reverse
    end

    def test_scores
      {title: 'Test Scores', rating: @test_scores.rating, weight: get_weight('Summary Rating Weight: Test Score Rating')} if @test_scores.visible?
    end

    def student_progress
      if @academic_progress.visible? && !@student_progress.has_data?
        {title: 'Academic Progress', rating: @academic_progress.academic_progress_rating, weight: get_weight('Summary Rating Weight: Academic Progress Rating')}
      elsif @student_progress.visible?
        {title: 'Student Progress', rating: @student_progress.rating, weight: get_weight('Summary Rating Weight: Student Progress Rating')}
      end
    end

    def college_readiness
      {title: 'College Readiness', rating: @college_readiness.rating, weight: get_weight('Summary Rating Weight: College Readiness Rating')} if @school.level_code =~ /h/
    end

    def equity
      if @equity_overview.has_rating?
        {title: 'Equity Overview', rating: @equity_overview.equity_rating, weight: get_weight('Summary Rating Weight: Equity Rating')}
      elsif @school_cache_data_reader.equity_adjustment_factor?
        {title: 'Equity adjustment factor', }
      end
    end

    def courses
      if @school.includes_level_code?(%w[m h]) || @courses.visible? || @stem_courses.visible?
        {title: 'Advanced Courses', rating: @courses.rating, weight: get_weight('Summary Rating Weight: Advanced Course Rating')}
      end
    end

    def summary_rating
      @school_cache_data_reader.gs_rating
    end

    def discipline
      if @school_cache_data_reader.discipline_flag?
        {title: 'Discipline flag', rating: '<span class="icon-flag red"></span>', weight: get_weight('Summary Rating Weight: Discipline Flag')}
      end
    end

    def attendance
      if @school_cache_data_reader.attendance_flag?
        {title: 'Attendance flag', rating: '<span class="icon-flag red"></span>', weight: get_weight('Summary Rating Weight: Absence Flag')}
      end
    end


    # def summary_rating
    #   #TODO fallback value if Summary Rating is not in the data cache?
    #   if @school_cache_data_reader.gsdata_data('Summary Rating').present?
    #     @_summary_rating ||= filter_rating('Summary Rating')
    #   end
    # end

    def last_updated
      @school_cache_data_reader.fetch_date_from_weight
    end

    def to_percent(decimal)
      (decimal*100).round.to_s + '%'
    end

    private

    def get_weight(key)
      if @school_cache_data_reader.gsdata_data(key).present?
        filter_rating(key).school_value.to_f
      end
    end

    def filter_rating(key)
      rating_weight = @school_cache_data_reader.gsdata_data(key)[key].map do |hash|
        GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: key))
      end.extend(GsdataCaching::GsDataValue::CollectionMethods)
      rating_weight
        .having_school_value
        .having_no_breakdown
        .having_most_recent_date
        .expect_only_one(
          key,
          school: {
            state: @school_cache_data_reader.school.state,
            id: @school_cache_data_reader.school.id
          }
        )
    end

  end
end

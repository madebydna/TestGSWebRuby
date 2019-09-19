module SchoolProfiles
  class SummaryRating

    attr_reader :school

    # The methods below rely on this mapping to pass along the correct title and weight to the summary tooltip.
    # NB: The 'weight' strings correspond to matching keys is the gsdata cache. Only change if the cache keys are also changing!
    # The titles are passed to the tooltip as is.
    RATING_WEIGHTS = {
      'Test Score Rating' => {title: 'Test Scores', weight: 'Summary Rating Weight: Test Score Rating' },
      'Academic Progress Rating' => {title: 'Academic Progress', weight: 'Summary Rating Weight: Academic Progress Rating'},
      'Student Progress Rating' => {title: 'Student Progress', weight: 'Summary Rating Weight: Student Progress Rating'},
      'College Readiness Rating' => {title: 'College Readiness', weight: 'Summary Rating Weight: College Readiness Rating'},
      'Equity Rating' => {title: 'Equity Overview', weight: 'Summary Rating Weight: Equity Rating'},
      'Equity Adjustment Factor' => {title: 'Equity Adjustment Factor', weight: 'Summary Rating Weight: Equity Adjustment Factor'},
      'Discipline Flag' => {title: 'Discipline Flag', weight: 'Summary Rating Weight: Discipline Flag'},
      'Attendance Flag' => {title: 'Attendance Flag', weight: 'Summary Rating Weight: Absence Flag'}
    }

    def initialize(test_scores, college_readiness, student_progress, academic_progress, equity_overview, stem_courses, school, school_cache_data_reader:)
      @test_scores = test_scores
      @student_progress = student_progress
      @academic_progress = academic_progress
      @college_readiness = college_readiness
      @equity_overview = equity_overview
      @stem_courses = stem_courses
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def content
      # each row is a hash in format: {title: Some Title, rating: 8, weight: .67}
      @_content ||= build_content_for_summary_rating_table
    end

    def test_scores_only?
      content.present? && content.length == 1 && content[0][:title] == RATING_WEIGHTS['Test Score Rating'][:title]
    end

    def build_content_for_summary_rating_table
      rating_array = [test_scores, student_progress, college_readiness, equity, discipline, attendance]
      rating_array.reject! {|row| row.nil? || row.empty? || row[:weight].nil? || row[:rating].nil?}
      rating_array.sort_by {|row| row[:weight]}.reverse
    end

    def test_scores
      {title: RATING_WEIGHTS['Test Score Rating'][:title], rating: @test_scores.rating, weight: get_school_value_for(RATING_WEIGHTS['Test Score Rating'][:weight])} if @test_scores.visible?
    end

    def student_progress
      if @academic_progress.visible? && !@student_progress.has_data?
        {title: RATING_WEIGHTS['Academic Progress Rating'][:title], rating: @academic_progress.academic_progress_rating, weight: get_school_value_for(RATING_WEIGHTS['Academic Progress Rating'][:weight])}
      elsif @student_progress.visible?
        {title: RATING_WEIGHTS['Student Progress Rating'][:title], rating: @student_progress.rating, weight: get_school_value_for(RATING_WEIGHTS['Student Progress Rating'][:weight])}
      end
    end

    def college_readiness
      {title: RATING_WEIGHTS['College Readiness Rating'][:title], rating: @college_readiness.rating, weight: get_school_value_for(RATING_WEIGHTS['College Readiness Rating'][:weight])} if @school.level_code =~ /h/
    end

    def equity
      if @equity_overview.has_rating?
        {title: RATING_WEIGHTS['Equity Rating'][:title], rating: @equity_overview.equity_rating, weight: get_school_value_for(RATING_WEIGHTS['Equity Rating'][:weight])}
      elsif @school_cache_data_reader.equity_adjustment_factor?
        {title: RATING_WEIGHTS['Equity Adjustment Factor'][:title], rating: get_school_value_for('Equity Adjustment Factor').round, weight: get_school_value_for(RATING_WEIGHTS['Equity Adjustment Factor'][:weight])}
      end
    end

    def equity_overview
      if @equity_overview.has_rating?
        {title: RATING_WEIGHTS['Equity Rating'][:title], rating: @equity_overview.equity_rating, weight: get_school_value_for(RATING_WEIGHTS['Equity Rating'][:weight])}
      end
    end

    def discipline
      if @school_cache_data_reader.discipline_flag?
        {title: RATING_WEIGHTS['Discipline Flag'][:title], rating: :flag, weight: get_school_value_for(RATING_WEIGHTS['Discipline Flag'][:weight])}
      end
    end

    def attendance
      if @school_cache_data_reader.attendance_flag?
        {title: RATING_WEIGHTS['Attendance Flag'][:title], rating: :flag, weight: get_school_value_for(RATING_WEIGHTS['Attendance Flag'][:weight])}
      end
    end

    def last_updated_date
      if test_scores_only?
        # Use date from the Test Score Rating. If that isn't present, fall back on the rating weight date.
        gsdata_obj = filter_rating(RATING_WEIGHTS['Test Score Rating'][:weight]) || @school_cache_data_reader.decorated_school.rating_object_for_key('Test Score Rating').try(:source_date_valid)
        sdv_timestamp = gsdata_obj.source_date_valid
      else
        sdv_timestamp = @school_cache_data_reader.decorated_school.rating_object_for_key('Summary Rating').try(:source_date_valid)
      end
      sdv_timestamp.to_date if sdv_timestamp
    end

    def last_updated
      date = last_updated_date
      @school_cache_data_reader.format_date date if date
    end

    def to_percent(decimal)
      (decimal*100).round.to_s + '%' if decimal
    end

    def weights_within_range?
      return false unless @school_cache_data_reader.rating_weight_values_array
      @school_cache_data_reader.rating_weight_values_array.reduce(:+).between?(90, 110)
    end

    def gs_rating
      @school_cache_data_reader.gs_rating
    end

    def self.scale(rating)
      raise ArgumentError.new('Rating must be numeric') unless rating.is_a?(Numeric)
      scope = 'school_profiles.summary_rating'
      key = 
        if rating <= 4
          'Below average'
        elsif rating <= 6
          'Average'
        elsif rating <= 10
          'Above average'
        end
      I18n.t(key, scope: scope)
    end

    private

    def get_school_value_for(key)
      if @school_cache_data_reader.ratings_data(key).present?
        filter_rating(key).school_value.to_f
      end
    end

    def filter_rating(key)
      rating_weight = (@school_cache_data_reader.ratings_data(key)[key] || []).map do |hash|
        GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: key))
      end.extend(GsdataCaching::GsDataValue::CollectionMethods)

      rating_weight
        .having_school_value
        .having_all_students_or_all_breakdowns_in(Omni::Breakdown::NOT_APPLICABLE)
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

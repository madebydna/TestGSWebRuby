module SchoolProfiles
  class EquityTestScores

    SUBJECT_ALL_PERCENTAGE = '200' # This is also used in react to determine different layout in ethnicity for All students
    BREAKDOWN_LOW_INCOME = 'Economically disadvantaged'
    BREAKDOWN_NOT_LOW_INCOME = 'Not economically disadvantaged'
    BREAKDOWN_ALL = 'All'
    LOW_INCOME_TOP = 'low_income'
    ETHNICITY_TOP = 'ethnicity'
    DISABILITIES_TOP = 'disabilities'
    SUBJECTS_TO_RETURN = 3
    NATIVE_AMERICAN = [
        'American Indian/Alaska Native',
        'Native American',
        'Native American or Native Alaskan'
    ]

    PACIFIC_ISLANDER = [
        'Pacific Islander',
        'Hawaiian Native/Pacific Islander',
        'Native Hawaiian or Other Pacific Islander'
    ]
    # BREAKDOWN_PACIFIC_ISLANDER_COMBO = 'Native Hawaiian or Other Pacific Islander'
    # BREAKDOWN_PACIFIC_ISLANDER = 'Pacific Islander'
    # BREAKDOWN_HAWAIIAN = 'Hawaiian'
    BREAKDOWN_DISABILITIES = 'Students with disabilities'

    #PUBLIC

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def low_income_test_scores_visible?
      low_income_hash.present?
    end

    def low_income_hash
      # TODO: sort breakdowns
      @_low_income_hash ||=(
        results = @school_cache_data_reader
          .recent_test_scores_with_subgroups
          .having_breakdown_in(low_income_breakdowns.keys)
        if results.any_subgroups?
          results
            .group_by_test
            .first(SUBJECTS_TO_RETURN)
        else
          nil
        end
      )
    end

    def low_income_breakdowns
      {BREAKDOWN_ALL => SUBJECT_ALL_PERCENTAGE, BREAKDOWN_LOW_INCOME=>'0', BREAKDOWN_NOT_LOW_INCOME=>'0'}
    end

  end
end

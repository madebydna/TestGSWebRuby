# frozen_string_literal: true

# cache data for state from the gsdata database
class StateRatingCacher < StateCacher
  CACHE_KEY = 'ratings'

  SUMMARY_RATING_DATA_TYPE_ID = 160
  TEST_SCORES_RATING_DATA_TYPE_ID = 155
  SUMMARY_RATING_NAME = 'Summary Rating'
  TEST_SCORES_RATING_NAME = 'Test Score Rating'

  # needs to contain
  # - rating type - summary or test
  # - description
  # - year or date
  #
  # Summary description is currently not in database and is static across states
  SUMMARY_DESCRIPTION = "The GreatSchools Rating helps parents compare schools within a state based on a variety of school quality indicators and provides a helpful picture of how effectively each school serves all of its students. Ratings are on a scale of 1 (below average) to 10 (above average) and can include test scores, college readiness, academic progress, advanced courses, equity, discipline and attendance data. We also advise parents to visit schools, consider other information on school performance and programs, and consider family needs as part of the school selection process."
  # Test scores rating description is in database and varies across states


  def test_rating
    Omni::DataSet.by_state(state).
                  where(data_type_id: TEST_SCORES_RATING_DATA_TYPE_ID).
                  where("description is NOT NULL").
                  order("date_valid desc")
  end

  def summary_rating
    Omni::DataSet.by_state(state).
                  where(data_type_id: SUMMARY_RATING_DATA_TYPE_ID).
                  order("date_valid desc")
  end
  #
  # Determine if it is summary or test by looking at all caches for all schools in a state and if any of them have a
  # Summary rating than it is a summary rating state.
  #
  # Otherwise it is a test score rating state and gets the date and description from the query above.
  # and max date on results
  #

  def build_hash_for_cache
    s = summary_rating&.first
    if s&.date_valid
      description = s.description.present? ? s.description : SUMMARY_DESCRIPTION
      result_to_hash(s.date_valid.year, description, SUMMARY_RATING_NAME)
    else
      tr = test_rating&.first
      if tr&.date_valid
        result_to_hash(tr.date_valid.year, tr.description, TEST_SCORES_RATING_NAME)
      else
        {}
      end
    end
  end

  def result_to_hash(year, description, type)
    {}.tap do |h|
      h[:year] = year
      h[:description] = description
      h[:type] = type
    end
  end

end

# frozen_string_literal: true

module Gsdata 
  # Note:
  #
  # The end goal is for GsDataValue::CollectionMethods and these collection
  # methods to be the same thing. We should be able to ask data mart documents
  # and collections of data values the same questions.
  #
  # To achieve requires thinking about a couple things when adding methods here
  #
  # 1) We have to write methods that dont assume the type of the
  # thing you're enumerating, and make both GsDataValue and DataValue
  # answer the same questions, such as "are you a test score rating?" or "are
  # you for a specific subgroup or all students?"
  #
  # 2) In some situations, the underlying objects (Data mart doc vs DataValue)
  # might not respond to the same questions (such as date_valid vs 
  # source_date_valid currently). In that case we should either make them the 
  # same (preferable), or have two separate implementations of 
  # #having_most_recent_date with the same name, in different modules,
  # and have all the identical collection methods in a third module

  module DataValueCollectionMethods
    def summary_rating_test_scores_weight
      test_scores_weight = find(&:summary_rating_test_score_weight?)
      test_scores_weight&.value
    end

    # this method is helpful since it knows that the weight
    # should be a string that is exactly '1'
    def summary_rating_is_test_scores_rating?
      summary_rating_test_scores_weight == '1'
    end
    
    def test_scores_rating
      find(&:test_scores_rating?)&.value&.to_i
    end

    def summary_rating
      if summary_rating_is_test_scores_rating?
        test_scores_rating
      end
      find(&:summary_rating?)&.value&.to_i
    end

    def having_most_recent_date
      max_source_date_valid = map(&:source_date_valid).max
      select { |dv| dv.source_date_valid == max_source_date_valid }.extend(this_module)
    end

    private

    def this_module
      Gsdata::DataValueCollectionMethods
    end
  end
end

# frozen_string_literal: true

module Omni
  class DataType < ActiveRecord::Base
    db_magic connection: :omni

    has_many :data_type_tags
    has_many :data_sets

    SUMMARY_RATING_DATA_TYPE_ID = 160
    TEST_SCORES_RATING_DATA_TYPE_ID = 155
    SUMMARY_RATING_NAME = 'Summary Rating'
    TEST_SCORES_RATING_NAME = 'Test Score Rating'

    # These DataType ids the metrics values for different entities
    # (e.g. school, district, state) could be split between different data_sets
    # Currently unused but we might want to potentially target them separately in the future
    SEPARATE_DATA_SETS_FOR_ENTITIES = [
      23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63, 67, 71, 75, 79,
      83, 87, 91, 95, 99, 103, 107, 111, 115, 119, 123, 128, 133,
      145, 149, 318, 342, 343, 344, 345, 346, 347, 348, 349, 350,
      351, 352, 353, 354, 355, 356, 357, 358, 359
    ]

  end
end
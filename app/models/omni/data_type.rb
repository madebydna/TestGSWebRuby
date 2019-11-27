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

  end
end
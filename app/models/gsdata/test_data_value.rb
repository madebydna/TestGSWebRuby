# frozen_string_literal: true

class TestDataValue < ActiveRecord::Base
  self.table_name = 'test_data_values'
  db_magic connection: :omni

  belongs_to :data_set

end

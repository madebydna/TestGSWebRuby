# frozen_string_literal: true

require 'ruby-prof'

class DataSet < ActiveRecord::Base
  self.table_name = 'data_sets'

  db_magic connection: :omni
  has_many :test_data_values
  has_many :data_type_tags
  belongs_to :data_type

end
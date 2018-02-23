# frozen_string_literal: true

class Breakdown < ActiveRecord::Base
  self.table_name = 'breakdowns'
  db_magic connection: :gsdata

  has_many :data_values_to_breakdowns, inverse_of: :breakdown
  has_many :data_values, through: :data_values_to_breakdowns, inverse_of: :breakdowns
end

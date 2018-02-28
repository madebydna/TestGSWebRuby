# frozen_string_literal: true

class DataValuesToBreakdown < ActiveRecord::Base
  self.table_name = 'data_values_to_breakdowns'
  db_magic connection: :gsdata

  attr_accessible :data_value_id, :breakdown_id

  belongs_to :data_value, inverse_of: :data_values_to_breakdowns
  belongs_to :breakdown, inverse_of: :data_values_to_breakdowns
end

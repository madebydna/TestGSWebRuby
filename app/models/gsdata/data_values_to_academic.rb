# frozen_string_literal: true

class DataValuesToAcademic < ActiveRecord::Base
  self.table_name = 'data_values_to_academics'
  db_magic connection: :gsdata

  attr_accessible :data_value_id, :academic_id

  belongs_to :data_value
  belongs_to :academic
end

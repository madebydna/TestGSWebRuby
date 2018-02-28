# frozen_string_literal: true

class DataType < ActiveRecord::Base
  self.table_name = 'data_types'
  db_magic connection: :gsdata

  attr_accessible :id, :name
end

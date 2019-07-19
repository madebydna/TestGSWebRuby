# frozen_string_literal: true

require 'ruby-prof'

class DataSet < ActiveRecord::Base
  self.table_name = 'data_sets'

  db_magic connection: :omni

end
